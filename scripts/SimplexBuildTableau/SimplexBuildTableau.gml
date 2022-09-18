/// @param maximize
/// @param constraintEquationArray
/// @param [objectiveFunction]

function SimplexBuildTableau(_maximize, _problemArray, _objectiveFunction = {})
{
    //The number of equations is used to determine how high the tableau needs to be
    //Add an extra row at the bottom for the objective function
    var _equationCount = array_length(_problemArray)+1;
    var _equationArray = array_create(_equationCount);
    array_copy(_equationArray, 0, _problemArray, 0, _equationCount-1);
    _equationArray[@ _equationCount-1] = _objectiveFunction;
    
    var _tableauWidth = 1; //Always two columns: one for for the value of the objective function, and one for the constant term
    
    var _variableCount = 0;
    var _variableArray = [];
    
    var _result = {};
    
    //Figure out how wide our tableau needs to be based on the number of unique variables
    //We want to analyze constraints and the objective function so let's create an array that combines the two
    var _variableDict = {};
    var _i = 0;
    repeat(_equationCount)
    {
        var _equationStruct = _equationArray[_i];
        var _termsArray = variable_struct_get_names(_equationStruct);
        
        var _weight = _equationStruct[$ "weight"] ?? __BIG_M_VERY_LARGE;
        
        //Do it alphabetically, because why not
        array_sort(_termsArray, true);
        
        var _j = 0;
        repeat(array_length(_termsArray))
        {
            var _term = _termsArray[_j];
            if (_term == "op")
            {
                switch(_equationStruct[$ _term])
                {
                    case "<=":
                    case "<":
                        _tableauWidth += 2; //Add both a surplus variable and artificial variable
                        if (_weight < __BIG_M_VERY_LARGE) _tableauWidth++; //One error variables
                    break;
                    
                    case "=":
                    case "==":
                        ++_tableauWidth; //Add a artificial variable
                        if (_weight < __BIG_M_VERY_LARGE) _tableauWidth += 2; //Two error variables
                    break;
                    
                    case ">=":
                    case ">":
                        _tableauWidth += 2; //Add both a surplus variable and artificial variable
                        if (_weight < __BIG_M_VERY_LARGE) _tableauWidth++; //One error variables
                    break;
                    
                    default:
                        show_error("Unsupported operator \"" + _equationStruct[$ _term] + "\"\n ", true);
                    break;
                }
            }
            else if ((_term == "const") || (_term == "weight"))
            {
                //We can ignore these, they're handled later
            }
            else if (!variable_struct_exists(_variableDict, _term))
            {
                _variableDict[$ _term] = _variableCount;
                array_push(_variableArray, _term);
                
                ++_variableCount;
                ++_tableauWidth;
                
                //At the same time, initialize our results struct
                _result[$ _term] = 0;
            }
            
            ++_j;
        }
        
        ++_i;
    }
    
    //Create the tableau!
    var _tableauGrid = ds_grid_create(_tableauWidth, _equationCount);
    var _workGrid    = ds_grid_create(_tableauWidth, 1);
    
    //Unpack our equatons into the tableau
    var _otherVariablesX = _variableCount;
    var _i = 0;
    repeat(_equationCount)
    {
        var _equationStruct = _equationArray[_i];
        var _weight = _equationStruct[$ "weight"] ?? __BIG_M_VERY_LARGE;
        
        //Unpack our variables into the tableau
        //TODO - Could we do this during the variable discovery phase?
        var _j = 0;
        repeat(_variableCount)
        {
            var _variableName = _variableArray[_j];
            var _coefficient = _equationStruct[$ _variableName];
            if (_coefficient != undefined) _tableauGrid[# _j, _i] = _coefficient;
            ++_j;
        }
        
        //Don't fiddle with the objective function...
        if (_i < _equationCount-1)
        {
            var _op       = _equationStruct.op;
            var _constant = _equationStruct[$ "const"] ?? 0;
            
            //If our constant term is negative, flip signs across this row
            var _reverse = 1;
            if (_constant < 0)
            {
                ds_grid_multiply_region(_tableauGrid,   0, _i, _variableCount-1, _i,   -1);
                _constant = -_constant;
                _reverse = -1;
            }
            
            _tableauGrid[# _tableauWidth-1, _i] = _constant;
            
            switch(_op)
            {
                case "<=":
                case "<":
                    _tableauGrid[# _otherVariablesX, _i] = _reverse; //Surplus variable
                    ++_otherVariablesX;
                    
                    _tableauGrid[# _otherVariablesX, _i] = 1; //Artificial variable
                    _tableauGrid[# _otherVariablesX, _equationCount-1] = __BIG_M_VERY_LARGE;
                    ++_otherVariablesX;
                    
                    if (_weight < __BIG_M_VERY_LARGE)
                    {
                        _tableauGrid[# _otherVariablesX, _i] = -_reverse; //Error variable
                        _tableauGrid[# _otherVariablesX, _equationCount-1] = _weight;
                        ++_otherVariablesX;
                    }
                    
                    if (_op == "<")
                    {
                        //If we have a simple "less than" sign then treat it as <= but with a tiny offset
                        _tableauGrid[# _tableauWidth-1, _i] -= _reverse*__BIG_M_VERY_SMALL;
                    }
                break;
                
                case "=":
                case "==":
                    _tableauGrid[# _otherVariablesX, _i] = 1; //Artificial variable
                    _tableauGrid[# _otherVariablesX, _equationCount-1] = __BIG_M_VERY_LARGE;
                    ++_otherVariablesX;
                    
                    if (_weight < __BIG_M_VERY_LARGE)
                    {
                        _tableauGrid[# _otherVariablesX, _i] = -1; //Error variable
                        _tableauGrid[# _otherVariablesX, _equationCount-1] = _weight;
                        ++_otherVariablesX;
                        
                        _tableauGrid[# _otherVariablesX, _i] = 1; //Error variable
                        _tableauGrid[# _otherVariablesX, _equationCount-1] = _weight;
                        ++_otherVariablesX;
                    }
                break;
                
                case ">=":
                case ">":
                    _tableauGrid[# _otherVariablesX, _i] = -_reverse; //Surplus variable
                    ++_otherVariablesX;
                    
                    _tableauGrid[# _otherVariablesX, _i] = 1; //Artificial variable
                    _tableauGrid[# _otherVariablesX, _equationCount-1] = __BIG_M_VERY_LARGE;
                    ++_otherVariablesX;
                    
                    if (_weight < __BIG_M_VERY_LARGE)
                    {
                        _tableauGrid[# _otherVariablesX, _i] = _reverse; //Error variable
                        _tableauGrid[# _otherVariablesX, _equationCount-1] = _weight;
                        ++_otherVariablesX;
                    }
                    
                    if (_op == ">")
                    {
                        //If we have a simple "greater than" sign then treat it as >= but with a tiny offset
                        _tableauGrid[# _tableauWidth-1, _i] += _reverse*__BIG_M_VERY_SMALL;
                    }
                break;
            }
        }
        
        ++_i;
    }
    
    if (_maximize)
    {
        //Flip the sign for the objective function if we're maximizing
        ds_grid_multiply_region(_tableauGrid, 0, _equationCount-1, _variableCount-1, _equationCount-1, -1);
    }
    
    //Eliminate M from the bottom of the artifical variable columns
    //We subtract each row with an artificial variable from the objective function
    var _i = 0;
    repeat(_equationCount-1)
    {
        ds_grid_add_grid_region(_workGrid,   _tableauGrid, 0, _i, _tableauWidth-1, _i,   0, 0);
        ++_i;
    }
    
    ds_grid_multiply_region(_workGrid,   0, 0, _tableauWidth-1, 0,   -__BIG_M_VERY_LARGE);
    ds_grid_add_grid_region(_tableauGrid,   _workGrid, 0, 0, _tableauWidth-1, 0,   0, _equationCount-1);
    
    ds_grid_destroy(_workGrid);
    
    return new __SimplexTableauClass(_tableauGrid, _variableArray);
}