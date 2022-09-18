/// @param constraintEquationArray

function SimplexSolverWeighted(_problemArray)
{
    var _tableau  = SimplexBuildTableau(false, _problemArray, {});
    var _solution = SimplexSolveTableau(_tableau);
    var _result   = _tableau.MapSolution(_solution);
    _tableau.Destroy();
    return _result;
}
