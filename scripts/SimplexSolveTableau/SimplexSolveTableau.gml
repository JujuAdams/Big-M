/// @param tableau

function SimplexSolveTableau(_tableau)
{
    __SimplexFindBasicVariables(_tableau);
    
    var _tableauGrid   = _tableau.__grid;
    var _variableArray = _tableau.__variableArray;
    
    var _tableauWidth  = ds_grid_width(_tableauGrid);
    var _equationCount = ds_grid_height(_tableauGrid);
    var _variableCount = array_length(_variableArray);
    
    var _workGrid = ds_grid_create(_tableauWidth, 1);
    
    var _basicVariablesXArray   = _tableau.__basicVariablesXArray;
    var _nonbasicVariablesArray = _tableau.__nonbasicVariablesArray;
    
    var _result = array_create(_variableCount, undefined);
    
    if (_tableau.__feasible)
    {
        //Build a data structure for tracking basic variables
        var _remappedBasicVariablesArray = array_create(array_length(_basicVariablesXArray));
        array_copy(_remappedBasicVariablesArray, 0, _basicVariablesXArray, 0, array_length(_basicVariablesXArray));
        
        //Pivot and eliminate negative values from the objective function
        while(true)
        {
            var _minValue = 0;
            var _minI     = undefined;
            var _pivotX   = undefined;
            
            var _i = 0;
            repeat(array_length(_nonbasicVariablesArray))
            {
                var _x = _nonbasicVariablesArray[_i];
                var _value = _tableauGrid[# _x, _equationCount-1];
                if (_value < _minValue)
                {
                    _minValue = _value;
                    _minI     = _i;
                    _pivotX   = _x;
                }
                
                ++_i;
            }
            
            if (_pivotX == undefined) break;
            
            var _pivotY   = undefined;
            var _minValue = infinity;
            
            var _y = 0;
            repeat(_equationCount-1)
            {
                var _value = _tableauGrid[# _pivotX, _y];
                if (_value > 0)
                {
                    _value = _tableauGrid[# _tableauWidth-1, _y] / _value;
                    if (_value < _minValue)
                    {
                        _minValue = _value;
                        _pivotY = _y;
                    }
                }
                
                ++_y;
            }
            
            _remappedBasicVariablesArray[@ _pivotY] = _pivotX;
            array_delete(_nonbasicVariablesArray, _minI, 1);
            
            //Multiply the pivot row by the coefficient we found, setting the pivot value to 1
            ds_grid_multiply_region(_tableauGrid, 0, _pivotY, _tableauWidth-1, _pivotY, 1/_tableauGrid[# _pivotX, _pivotY]);
            
            var _y = 0;
            repeat(_equationCount)
            {
                if (_y != _pivotY)
                {
                    var _destinationTerm = _tableauGrid[# _pivotX, _y];
                    if (_destinationTerm != 0)
                    {
                        ds_grid_set_grid_region(_workGrid,   _tableauGrid, 0, _pivotY, _tableauWidth-1, _pivotY,   0, 0);
                        ds_grid_multiply_region(_workGrid, 0, 0, _tableauWidth-1, 0, -_destinationTerm);
                        ds_grid_add_grid_region(_tableauGrid,   _workGrid, 0, 0, _tableauWidth-1, 0,   0, _y);
                    }
                }
                
                ++_y;
            }
        }
        
        //Then set our variables to values found in our tableau
        //We ignore any surplus/artificial variables we added
        var _i = 0;
        repeat(array_length(_remappedBasicVariablesArray))
        {
            var _y = _remappedBasicVariablesArray[_i];
            if (_y < _variableCount) _result[@ _y] = _tableauGrid[# _tableauWidth-1, _i];
            ++_i;
        }
    }
    
    ds_grid_destroy(_workGrid);
    
    return _result;
}
