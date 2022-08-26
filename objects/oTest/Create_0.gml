//constraints = [
//    MakeConstraint("A.left",   "=",               20),
//    MakeConstraint("A.top",    "=",               20),
//    MakeConstraint("A.right",  "=", room_width  - 20),
//    MakeConstraint("A.bottom", "=", room_height - 20),
//    
//    MakeConstraint("B.x",      "=", "A.x"),
//    MakeConstraint("B.width",  "<", "A.width", -50),
//    MakeConstraint("B.top",    "=", "A.top", 100),
//    MakeConstraint("B.height", ">", 100),
//    MakeConstraint("B.bottom", "<", "A.bottom", -50),
//];
//
//solution = SimplexSolver(constraints, { "B.bottom": -1 });
//
//show_debug_message(snap_to_json(solution, true, true));
