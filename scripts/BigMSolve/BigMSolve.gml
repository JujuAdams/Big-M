/// @param problemArray
/// @param objectiveFunction

#macro __BIG_M_CONST  1000000

function BigMSolve(_problemArray, _objectiveFunction)
{
    var _time = get_timer();
    
    var _equationCount = array_length(_problemArray)+1; //Add an extra row at the bottom for the objective function
    var _equationArray = array_create(_equationCount);
    array_copy(_equationArray, 0, _problemArray, 0, _equationCount-1);
    _equationArray[@ _equationCount-1] = _objectiveFunction;
    
    var _variableCount = 0;
    var _variableDict  = {};
    var _variableArray = [];
    
    var _tableauW = 1; //Always two columns: one for for the value of the objective function, and one for the constant term
    
    //Figure out how big our tableau needs to be based on the number of unique variables
    var _i = 0;
    repeat(_equationCount)
    {
        var _equationStruct = _equationArray[_i];
        var _equationTermsArray = variable_struct_get_names(_equationStruct);
        array_sort(_equationTermsArray, true);
        
        var _j = 0;
        repeat(array_length(_equationTermsArray))
        {
            var _term = _equationTermsArray[_j];
            if (_term == "op")
            {
                switch(_equationStruct[$ _term])
                {
                    case "<=": ++_tableauW;    break; //Surplus variable
                    case "=":  ++_tableauW;    break; //Artificial variable
                    case ">=": _tableauW += 2; break; //Surplus variable and artificial variable
                    default: show_error("Unsupported operator \"" + _equationStruct[$ _term] + "\"\n ", true); break;
                }
            }
            else if (_term == "constant")
            {
                
            }
            else if (!variable_struct_exists(_variableDict, _term))
            {
                _variableDict[$ _term] = _variableCount;
                array_push(_variableArray, _term);
                
                ++_variableCount;
                ++_tableauW;
            }
            
            ++_j;
        }
        
        ++_i;
    }
    
    var _tableau = ds_grid_create(_tableauW, _equationCount);
    var _workGrid = ds_grid_create(_tableauW, 1);
    
    //Unpack our equatons into the tableau
    var _otherVariablesX = _variableCount;
    var _rowsWithArtificalVariablesArray = [];
    var _i = 0;
    repeat(_equationCount)
    {
        var _equationStruct = _equationArray[_i];
        
        //Unpack our variables into the tableau
        var _j = 0;
        repeat(_variableCount)
        {
            var _variableName = _variableArray[_j];
            var _coefficient = _equationStruct[$ _variableName];
            if (_coefficient != undefined) _tableau[# _j, _i] = _coefficient;
            ++_j;
        }
        
        if (_i < _equationCount-1)
        {
            switch(_equationStruct.op)
            {
                case "<=":
                    _tableau[# _otherVariablesX, _i] = 1; //Surplus variable
                    ++_otherVariablesX;
                break;
                
                case "=":
                    _tableau[# _otherVariablesX, _i] = 1; //Artificial variable
                    _tableau[# _otherVariablesX, _equationCount-1] = -__BIG_M_CONST;
                    ++_otherVariablesX;
                    
                    array_push(_rowsWithArtificalVariablesArray, _i);
                break;
                
                case ">=":
                    _tableau[# _otherVariablesX, _i] = -1; //Surplus variable
                    ++_otherVariablesX;
                    _tableau[# _otherVariablesX, _i] = 1; //Artificial variable
                    _tableau[# _otherVariablesX, _equationCount-1] = -__BIG_M_CONST;
                    ++_otherVariablesX;
                    
                    array_push(_rowsWithArtificalVariablesArray, _i);
                break;
            }
            
            _tableau[# _tableauW-1, _i] = _equationStruct.constant;
        }
        
        ++_i;
    }
    
    //Flip the sign for the objective function
    ds_grid_multiply_region(_tableau, 0, _equationCount-1, _tableauW-1, _equationCount-1, -1);
    
    //Eliminate M from the bottom of the artifical variable columns
    //We subtract each row with an artificial variable from the objective function
    ds_grid_clear(_workGrid, 0);
    var _i = 0;
    repeat(array_length(_rowsWithArtificalVariablesArray))
    {
        var _y = _rowsWithArtificalVariablesArray[_i];
        ds_grid_add_grid_region(_workGrid,   _tableau, 0, _y, _tableauW-1, _y,   0, 0);
        ++_i;
    }
    
    ds_grid_multiply_region(_workGrid,   0, 0, _tableauW-1, 0,   -__BIG_M_CONST);
    ds_grid_add_grid_region(_tableau,   _workGrid, 0, 0, _tableauW-1, 0,   0, _equationCount-1);
    
    //Pick basic and non-basic variables
    var _basicRowArray = array_create(_equationCount, 0);
    var _basicVariablesXArray   = [];
    var _basicVariablesYArray   = [];
    var _nonbasicVariablesArray = [];
    
    var _i = 0;
    repeat(_tableauW-2) //Ignore the objective function and constant terms
    {
        var _min = ds_grid_get_min(_tableau, _i, 0, _i, _equationCount-1);
        var _max = ds_grid_get_max(_tableau, _i, 0, _i, _equationCount-1);
        var _sum = ds_grid_get_sum(_tableau, _i, 0, _i, _equationCount-1);
        
        if (((_min != 0) && (_max == 0) && (_sum == _min))
        ||  ((_min == 0) && (_max != 0) && (_sum == _max)))
        {
            var _y = ds_grid_value_y(_tableau, _i, 0, _i, _equationCount-1, _sum);
            _basicRowArray[@ _y]++;
            array_push(_basicVariablesXArray, _i);
            array_push(_basicVariablesYArray, _y);
        }
        else
        {
            array_push(_nonbasicVariablesArray, _i);
        }
        
        ++_i;
    }
    
    var _i = array_length(_basicVariablesYArray)-1;
    repeat(_i+1)
    {
        if (_basicRowArray[_i] > 1)
        {
            array_delete(_basicVariablesXArray, _i, 1);
            array_delete(_basicVariablesYArray, _i, 1);
            array_push(_nonbasicVariablesArray, _i);
        }
        
        --_i;
    }
    
    var _remappedBasicVariablesArray = array_create(array_length(_basicVariablesXArray));
    array_copy(_remappedBasicVariablesArray, 0, _basicVariablesXArray, 0, array_length(_basicVariablesXArray));
    
    //Feasibility test
    //After setting non-basic variables to zero, if any basic variables are negative then the problem is infeasible
    var _i = 0;
    repeat(array_length(_basicVariablesYArray))
    {
        var _y = _basicVariablesYArray[_i];
        if (_tableau[# _tableauW-1, _y] < 0)
        {
            ds_grid_destroy(_tableau);
            ds_grid_destroy(_workGrid);
            return undefined;
        }
        
        ++_i;
    }
    
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
            var _value = _tableau[# _x, _equationCount-1];
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
            var _value = _tableau[# _pivotX, _y];
            if (_value > 0)
            {
                _value = _tableau[# _tableauW-1, _y] / _value;
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
        ds_grid_multiply_region(_tableau, 0, _pivotY, _tableauW-1, _pivotY, 1/_tableau[# _pivotX, _pivotY]);
        
        var _y = 0;
        repeat(_equationCount)
        {
            if (_y != _pivotY)
            {
                var _destinationTerm = _tableau[# _pivotX, _y];
                if (_destinationTerm != 0)
                {
                    ds_grid_set_grid_region(_workGrid,   _tableau, 0, _pivotY, _tableauW-1, _pivotY,   0, 0);
                    ds_grid_multiply_region(_workGrid, 0, 0, _tableauW-1, 0, -_destinationTerm);
                    ds_grid_add_grid_region(_tableau,   _workGrid, 0, 0, _tableauW-1, 0,   0, _y);
                }
            }
            
            ++_y;
        }
    }
    
    //Build our output struct
    //We start will all input variables defaulting to 0
    var _output = {};
    var _i = 0;
    repeat(array_length(_variableArray))
    {
        _output[$ _variableArray[_i]] = 0;
        ++_i;
    }
    
    //Then set our variables to values found in our tableau
    //We ignore any surplus/artificial variables we added
    var _i = 0;
    repeat(array_length(_remappedBasicVariablesArray))
    {
        var _y = _remappedBasicVariablesArray[_i];
        if (_y < _variableCount)
        {
            _output[$ _variableArray[_y]] = _tableau[# _tableauW-1, _i];
        }
        
        ++_i;
    }
    
    ds_grid_destroy(_tableau);
    ds_grid_destroy(_workGrid);
    
    show_debug_message(string(get_timer() - _time) + "us");
    
    return _output;
}