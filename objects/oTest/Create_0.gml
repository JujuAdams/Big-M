result = BigMSolve(
[
    { x1: 1, x2: 1, x3: 0, op: "<=", constant: 20 },
    { x1: 1, x2: 0, x3: 1, op: "=",  constant:  5 },
    { x1: 0, x2: 1, x3: 1, op: ">=", constant: 10 },
],
{ x1: 1, x2: -1, x3: 3 });

show_debug_message(result);
