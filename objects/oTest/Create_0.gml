solution = SimplexSolver(
    //Constraints
    [
        { Al:  1,                                 op: "==", const:   0 },
        { Al: -1,   Ar:  1,                       op: "==", const: 720 },
        { Al:  0.5, Ar:  0.5, Bl: -0.5, Br: -0.5, op: "==", const:   0 },
        { Al:  1,   Ar: -1,   Bl: -1,   Br:  1,   op: "<=", const: -40 },
    ],
    
    //Objective function (maximize)
    {
        Al: -1, Ar:  1,
        Bl: -1, Br:  1,
    }
);

show_debug_message(solution);
