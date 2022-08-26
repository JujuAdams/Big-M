constants = {
    roomWidth:  room_width,
    roomHeight: room_height,
    mouseY: mouse_y,
};

constraints = [
    "A.left   = 20",
    "A.top    = 20",
    "A.right  = roomWidth  - 20",
    "A.bottom = roomHeight - 20",
    
    "B.x      = A.x",
    "B.width  < A.width - 50",
    
    "B.top    > A.top + 25",
    "B.height > 100",
    "B.height < 200",
    "B.bottom < A.bottom - 25",
    "B.y      = mouseY",
];

ParseExpressionArray(constraints, constants);
solution = SimplexSolver(constraints, { "A.top": 1000, });

var _drawMemberFunc = function(_struct, _name, _outline)
{
    draw_rectangle(_struct[$ _name + ".left"], _struct[$ _name + ".top"], _struct[$ _name + ".right"], _struct[$ _name + ".bottom"], _outline);
}

draw_circle(mouse_x, mouse_y, 4, false);
draw_circle(mouse_x, mouse_y, 14, true);
_drawMemberFunc(solution, "A", true);
_drawMemberFunc(solution, "B", true);
