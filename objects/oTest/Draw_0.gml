var _solution = SimplexSolver(false,
[
    {x: 1, op: ">=", const: 10},
    {x: 1, op: "<=", const: 20},
],
{x: 1});

draw_text(10, 10, _solution.x);



_solution = SimplexSolverWeighted(
[
    {x: 1, op: "<=", const: 10, weight: 2},
    {x: 1, op: "==", const: 20, weight: 1},
]);

draw_text(10, 30, _solution.x);
