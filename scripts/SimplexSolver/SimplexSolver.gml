/// @param maximize
/// @param constraintEquationArray
/// @param [objectiveFunction]

function SimplexSolver(_maximize, _problemArray, _objectiveFunction = {})
{
    var _tableau  = SimplexBuildTableau(_maximize, _problemArray, _objectiveFunction);
    var _solution = SimplexSolveTableau(_tableau);
    var _result   = _tableau.MapSolution(_solution);
    _tableau.Destroy();
    return _result;
}
