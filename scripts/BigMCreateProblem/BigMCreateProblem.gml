/// @param problemArray
/// @param objectiveFunction

function BigMCreateProblem(_problemArray, _objectiveFunction)
{
    return new __BigMClassProblem(_problemArray, _objectiveFunction);
}

function __BigMClassProblem() constructor
{
    __variableArray = [];
    __tableauGrid   = ds_grid_create(10, 10);
    __constantGrid  = ds_grid_create(10, 1);
    
    __constantStruct = {};
    __constantInfluenceArray = [];
    
    static GetConstantStruct = function()
    {
        return __constantStruct;
    }
    
    static Destroy = function()
    {
        ds_grid_destroy(__tableauGrid);
    }
    
    static Solve = function()
    {
        
    }
}
