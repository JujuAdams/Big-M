/// @param tableau

function __SimplexFindBasicVariables(_tableau)
{
    var _tableauGrid = _tableau.__grid;
    
    var _tableauWidth  = ds_grid_width(_tableauGrid);
    var _equationCount = ds_grid_height(_tableauGrid);
    
    var _basicVariablesXArray   = _tableau.__basicVariablesXArray;
    var _basicVariablesYArray   = _tableau.__basicVariablesYArray;
    var _nonbasicVariablesArray = _tableau.__nonbasicVariablesArray;
    
    //Identify basic and non-basic variables
    var _basicCountArray = array_create(_equationCount, 0);
    
    var _i = 0;
    repeat(_tableauWidth-1) //Ignore the constant terms
    {
        //Using a hack here to determine if a column has only one non-zero element
        var _min = ds_grid_get_min(_tableauGrid, _i, 0, _i, _equationCount-1);
        var _max = ds_grid_get_max(_tableauGrid, _i, 0, _i, _equationCount-1);
        var _sum = ds_grid_get_sum(_tableauGrid, _i, 0, _i, _equationCount-1);
        
        if (((_min != 0) && (_max == 0) && (_sum == _min))
        ||  ((_min == 0) && (_max != 0) && (_sum == _max)))
        {
            var _y = ds_grid_value_y(_tableauGrid, _i, 0, _i, _equationCount-1, _sum);
            _basicCountArray[@ _y]++;
            array_push(_basicVariablesXArray, _i);
            array_push(_basicVariablesYArray, _y);
        }
        else
        {
            array_push(_nonbasicVariablesArray, _i);
        }
        
        ++_i;
    }
    
    //Basic variables cannot share a row with other basic variables
    var _i = array_length(_basicVariablesYArray)-1;
    repeat(_i+1)
    {
        if (_basicCountArray[_i] > 1)
        {
            array_delete(_basicVariablesXArray, _i, 1);
            array_delete(_basicVariablesYArray, _i, 1);
            array_push(_nonbasicVariablesArray, _i);
        }
        
        --_i;
    }
    
    //Feasibility test
    //After setting non-basic variables to zero, if the value of any basic variables are negative then the problem is infeasible
    var _feasible = true;
    var _i = 0;
    repeat(array_length(_basicVariablesYArray))
    {
        var _y = _basicVariablesYArray[_i];
        if (_tableauGrid[# _tableauWidth-1, _y] < 0)
        {
            _feasible = false;
            break;
        }
        
        ++_i;
    }
    
    _tableau.__feasible = _feasible;
}
