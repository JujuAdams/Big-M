function __BentoSolverEnd()
{
    var _solution = SimplexSolverWeighted(global.__bentoSystemConstraints);
    
    var _namesArray = variable_struct_get_names(_solution);
    var _i = 0;
    repeat(array_length(_namesArray))
    {
        var _name = _namesArray[_i];
        
        var _pointer  = global.__bentoSystemVariableMapping[$ _name];
        var _struct   = _pointer.struct;
        var _variable = _pointer.variable;
        
        _struct[$ _variable] = _solution[$ _name];
        
        ++_i;
    }
}