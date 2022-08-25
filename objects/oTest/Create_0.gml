problem = BigMCreateProblem(
    //Constraints
    [
        { x1: 1, x2: 1, x3: 0, op: "<=", const: 20 },
        { x1: 1, x2: 0, x3: 1, op: "==", const:  5 },
        { x1: 0, x2: 1, x3: 1, op: ">=", const: 10 },
    ],
    
    //Objective function (maximize)
    { x1: 1, x2: -1, x3: 3 },
    
    //Constants (always LHS)
    {
    }
);

show_debug_message(problem.Solve());
