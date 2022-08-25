/// @param constraintEquationArray
/// @param objectiveFunction

#macro __BIG_M_VERY_LARGE  1000000
#macro __BIG_M_VERY_SMALL  0.00001

function BigMCreateProblem(_problemArray, _objectiveFunction)
{
    return new __BigMClassProblem(_problemArray, _objectiveFunction);
}

function __BigMClassProblem(_problemArray, _objectiveFunction) constructor
{
    #region Initialize
    
    static __workGrid      = ds_grid_create(1, 1);
    static __outputTableau = ds_grid_create(1, 1);
    
    __feasible = false;
    
    //The number of equations is used to determine how high the tableau needs to be
    //Add an extra row at the bottom for the objective function
    __equationCount = array_length(_problemArray)+1;
    
    __basicVariablesXArray   = [];
    __basicVariablesYArray   = [];
    __nonbasicVariablesArray = [];
    
    __tableauWidth = 1; //Always two columns: one for for the value of the objective function, and one for the constant term
    __tableauGrid  = undefined; //We create this after determining the necessary width
    
    __variableCount = 0;
    __variableArray = [];
    
    __result = {};
    
    //Figure out how wide our tableau needs to be based on the number of unique variables
    //We want to analyze constraints and the objective function so let's create an array that combines the two
    var _equationArray = array_create(__equationCount);
    array_copy(_equationArray, 0, _problemArray, 0, __equationCount-1);
    _equationArray[@ __equationCount-1] = _objectiveFunction;
    
    var _variableDict = {};
    var _i = 0;
    repeat(__equationCount)
    {
        var _equationStruct = _equationArray[_i];
        var _equationTermsArray = variable_struct_get_names(_equationStruct);
        
        //Do it alphabetically, because why not
        array_sort(_equationTermsArray, true);
        
        var _j = 0;
        repeat(array_length(_equationTermsArray))
        {
            var _term = _equationTermsArray[_j];
            if (_term == "op")
            {
                switch(_equationStruct[$ _term])
                {
                    case "<=":
                    case "<":
                        ++__tableauWidth; //Add a surplus variable
                    break;
                    
                    case "=":
                    case "==":
                        ++__tableauWidth; //Add a artificial variable
                    break;
                    
                    case ">=":
                    case ">":
                        __tableauWidth += 2; //Add both a surplus variable and artificial variable
                    break;
                    
                    default:
                        show_error("Unsupported operator \"" + _equationStruct[$ _term] + "\"\n ", true);
                    break;
                }
            }
            else if (_term == "constant")
            {
                //We can ignore these for now
            }
            else if (!variable_struct_exists(_variableDict, _term))
            {
                _variableDict[$ _term] = __variableCount;
                array_push(__variableArray, _term);
                
                ++__variableCount;
                ++__tableauWidth;
                
                //At the same time, initialize our results struct
                __result[$ _term] = 0;
            }
            
            ++_j;
        }
        
        ++_i;
    }
    
    //Create the tableau!
    __tableauGrid = ds_grid_create(__tableauWidth, __equationCount);
    
    //Unpack our equatons into the tableau
    var _otherVariablesX = __variableCount;
    var _rowsWithArtificalVariablesArray = [];
    var _i = 0;
    repeat(__equationCount)
    {
        var _equationStruct = _equationArray[_i];
        
        //Unpack our variables into the tableau
        //TODO - Could we do this during the variable discovery phase?
        var _j = 0;
        repeat(__variableCount)
        {
            var _variableName = __variableArray[_j];
            var _coefficient = _equationStruct[$ _variableName];
            if (_coefficient != undefined) __tableauGrid[# _j, _i] = _coefficient;
            ++_j;
        }
        
        //Don't fiddle with the objective function
        if (_i < __equationCount-1)
        {
            __tableauGrid[# __tableauWidth-1, _i] = _equationStruct.constant;
            
            var _op = _equationStruct.op;
            switch(_op)
            {
                case "<=":
                case "<":
                    __tableauGrid[# _otherVariablesX, _i] = 1; //Surplus variable
                    ++_otherVariablesX;
                    
                    if (_op == "<")
                    {
                        //If we have a simple "less than" sign then treat it as <= but with a tiny offset
                        __tableauGrid[# __tableauWidth-1, _i] -= __BIG_M_VERY_SMALL;
                    }
                break;
                
                case "=":
                case "==":
                    __tableauGrid[# _otherVariablesX, _i] = 1; //Artificial variable
                    __tableauGrid[# _otherVariablesX, __equationCount-1] = -__BIG_M_VERY_LARGE;
                    ++_otherVariablesX;
                    
                    array_push(_rowsWithArtificalVariablesArray, _i);
                break;
                
                case ">=":
                case ">":
                    __tableauGrid[# _otherVariablesX, _i] = -1; //Surplus variable
                    ++_otherVariablesX;
                    __tableauGrid[# _otherVariablesX, _i] = 1; //Artificial variable
                    __tableauGrid[# _otherVariablesX, __equationCount-1] = -__BIG_M_VERY_LARGE;
                    ++_otherVariablesX;
                    
                    array_push(_rowsWithArtificalVariablesArray, _i);
                    
                    if (_op == ">")
                    {
                        //If we have a simple "greater than" sign then treat it as >= but with a tiny offset
                        __tableauGrid[# __tableauWidth-1, _i] += __BIG_M_VERY_SMALL;
                    }
                break;
            }
        }
        
        ++_i;
    }
    
    //Flip the sign for the objective function
    ds_grid_multiply_region(__tableauGrid, 0, __equationCount-1, __tableauWidth-1, __equationCount-1, -1);
    
    //Eliminate M from the bottom of the artifical variable columns
    //We subtract each row with an artificial variable from the objective function
    ds_grid_resize(__workGrid, __tableauWidth, 1);
    ds_grid_clear(__workGrid, 0);
    
    var _i = 0;
    repeat(array_length(_rowsWithArtificalVariablesArray))
    {
        var _y = _rowsWithArtificalVariablesArray[_i];
        ds_grid_add_grid_region(__workGrid,   __tableauGrid, 0, _y, __tableauWidth-1, _y,   0, 0);
        ++_i;
    }
    
    ds_grid_multiply_region(__workGrid,   0, 0, __tableauWidth-1, 0,   -__BIG_M_VERY_LARGE);
    ds_grid_add_grid_region(__tableauGrid,   __workGrid, 0, 0, __tableauWidth-1, 0,   0, __equationCount-1);
    
    //Identify basic and non-basic variables
    var _basicCountArray = array_create(__equationCount, 0);
    
    var _i = 0;
    repeat(__tableauWidth-1) //Ignore the constant terms
    {
        //Using a hack here to determine if a column has only one non-zero element
        var _min = ds_grid_get_min(__tableauGrid, _i, 0, _i, __equationCount-1);
        var _max = ds_grid_get_max(__tableauGrid, _i, 0, _i, __equationCount-1);
        var _sum = ds_grid_get_sum(__tableauGrid, _i, 0, _i, __equationCount-1);
        
        if (((_min != 0) && (_max == 0) && (_sum == _min))
        ||  ((_min == 0) && (_max != 0) && (_sum == _max)))
        {
            var _y = ds_grid_value_y(__tableauGrid, _i, 0, _i, __equationCount-1, _sum);
            _basicCountArray[@ _y]++;
            array_push(__basicVariablesXArray, _i);
            array_push(__basicVariablesYArray, _y);
        }
        else
        {
            array_push(__nonbasicVariablesArray, _i);
        }
        
        ++_i;
    }
    
    //Basic variables cannot share a row with other basic variables
    var _i = array_length(__basicVariablesYArray)-1;
    repeat(_i+1)
    {
        if (_basicCountArray[_i] > 1)
        {
            array_delete(__basicVariablesXArray, _i, 1);
            array_delete(__basicVariablesYArray, _i, 1);
            array_push(__nonbasicVariablesArray, _i);
        }
        
        --_i;
    }
    
    //Feasibility test
    //After setting non-basic variables to zero, if the value of any basic variables are negative then the problem is infeasible
    var _feasible = true;
    var _i = 0;
    repeat(array_length(__basicVariablesYArray))
    {
        var _y = __basicVariablesYArray[_i];
        if (__tableauGrid[# __tableauWidth-1, _y] < 0)
        {
            _feasible = false;
            break;
        }
        
        ++_i;
    }
    
    __feasible = _feasible;
    
    #endregion
    
    
    
    static Solve = function()
    {
        //Reset our result struct
        //We start will all input variables defaulting to 0
        var _i = 0;
        repeat(array_length(__variableArray))
        {
            __result[$ __variableArray[_i]] = 0;
            ++_i;
        }
        
        if (__feasible)
        {
            //Make a copy of the original tableau so we can operate freely and not worry about trashing cached data
            ds_grid_resize(__outputTableau, __tableauWidth, __equationCount);
            ds_grid_copy(__outputTableau, __tableauGrid);
            
            //We also need to resize the work grid since that gets reused between Big M struct instances
            ds_grid_resize(__workGrid, __tableauWidth, 1);
            ds_grid_clear(__workGrid, 0);
            
            var _nonbasicVariablesArray = array_create(array_length(__nonbasicVariablesArray));
            array_copy(_nonbasicVariablesArray, 0, __nonbasicVariablesArray, 0, array_length(__nonbasicVariablesArray));
    
            var _remappedBasicVariablesArray = array_create(array_length(__basicVariablesXArray));
            array_copy(_remappedBasicVariablesArray, 0, __basicVariablesXArray, 0, array_length(__basicVariablesXArray));
            
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
                    var _value = __outputTableau[# _x, __equationCount-1];
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
                repeat(__equationCount-1)
                {
                    var _value = __outputTableau[# _pivotX, _y];
                    if (_value > 0)
                    {
                        _value = __outputTableau[# __tableauWidth-1, _y] / _value;
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
                ds_grid_multiply_region(__outputTableau, 0, _pivotY, __tableauWidth-1, _pivotY, 1/__outputTableau[# _pivotX, _pivotY]);
                
                var _y = 0;
                repeat(__equationCount)
                {
                    if (_y != _pivotY)
                    {
                        var _destinationTerm = __outputTableau[# _pivotX, _y];
                        if (_destinationTerm != 0)
                        {
                            ds_grid_set_grid_region(__workGrid,   __outputTableau, 0, _pivotY, __tableauWidth-1, _pivotY,   0, 0);
                            ds_grid_multiply_region(__workGrid, 0, 0, __tableauWidth-1, 0, -_destinationTerm);
                            ds_grid_add_grid_region(__outputTableau,   __workGrid, 0, 0, __tableauWidth-1, 0,   0, _y);
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
                if (_y < __variableCount) __result[$ __variableArray[_y]] = __outputTableau[# __tableauWidth-1, _i];
                ++_i;
            }
        }
        
        return __result;
    }
    
    
    
    static GetResult = function()
    {
        return __result;
    }
    
    static GetVariableCount = function()
    {
        return __variableCount;
    }
    
    static GetVariableNames = function()
    {
        return __variableArray;
    }
    
    static GetFeasible = function()
    {
        return __feasible;
    }
    
    static Destroy = function()
    {
        ds_grid_destroy(__tableauGrid);
    }
}
