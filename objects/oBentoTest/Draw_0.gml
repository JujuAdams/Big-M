with(BentoConstants)
{
    self.room_width  = room_width;
    self.room_height = room_height;
    self.mouse_x     = mouse_x;
    self.mouse_y     = mouse_y;
    padding          = 20;
}

A = BentoBox()
    .Constraint("left   = 20")
    .Constraint("top    = 20")
    .Constraint("right  = room_width  - padding")
    .Constraint("bottom = room_height - padding");

BentoInheritStart(A);
    B = BentoBox()
        .Constraint("x      = ^.x")
        .Constraint("width  = ^.width - 2*padding")
        .Constraint("top    > ^.top   + padding")
        .Constraint("height > 100")
        .Constraint("height < 200")
        .Constraint("bottom < ^.bottom - padding")
        .WeakConstraint("y = mouse_y");
    
    BentoInheritStart(B);
        C = BentoBox()
            .Constraint("width  > 60")
            .Constraint("width  < 120")
            .Constraint("left   > ^.left   + padding")
            .Constraint("right  < ^.right  - padding")
            .Constraint("top    = ^.top    + padding")
            .Constraint("bottom = ^.bottom - padding")
            .WeakConstraint("x = mouse_x");
    
    BentoInheritEnd();
BentoInheritEnd();

A.Instantiate();

A.DrawWireframe();
B.DrawWireframe();
C.DrawWireframe();
