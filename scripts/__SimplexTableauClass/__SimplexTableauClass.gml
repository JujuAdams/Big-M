/// @param grid
/// @param variableArray

function __SimplexTableauClass(_grid, _variableArray) constructor
{
    __grid          = _grid;
    __variableArray = _variableArray;
    
    __feasible = undefined;
    
    __basicVariablesXArray   = [];
    __basicVariablesYArray   = [];
    __nonbasicVariablesArray = [];
    
    
    
    static GetVariables = function()
    {
        return __variableArray;
    }
    
    static MapSolution = function(_solution)
    {
        var _result = {};
        
        var _i = 0;
        repeat(array_length(_solution))
        {
            _result[$ __variableArray[_i]] = _solution[_i];
            ++_i;
        }
        
        return _result;
    }
    
    static Destroy = function()
    {
        ds_grid_destroy(__grid);
    }
}