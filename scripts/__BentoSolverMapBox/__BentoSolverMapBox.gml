/// @param context

function __BentoSolverMapBox(_context)
{
    var _contextName = _context.__bentoUniqueGlobalName;
    
    global.__bentoSystemVariableMapping[$ _contextName + ".left"] = {
        struct:   _context,
        variable: "left",
    };
    
    global.__bentoSystemVariableMapping[$ _contextName + ".top"] = {
        struct:   _context,
        variable: "top",
    };
    
    global.__bentoSystemVariableMapping[$ _contextName + ".right"] = {
        struct:   _context,
        variable: "right",
    };
    
    global.__bentoSystemVariableMapping[$ _contextName + ".bottom"] = {
        struct:   _context,
        variable: "bottom",
    };
}