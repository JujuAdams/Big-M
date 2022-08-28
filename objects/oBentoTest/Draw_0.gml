with(BentoConstants)
{
    self.room_width  = room_width;
    self.room_height = room_height;
    self.mouse_x     = mouse_x;
    self.mouse_y     = mouse_y;
    padding          = 20;
}

A = BentoBox()
    .Constraint("left   = 20",
                "top    = 20",
                "right  = room_width  - 20",
                "bottom = room_height - 20");

BentoInheritStart(A);
    
    B = BentoBox()
        .Constraint("x      = ^.x",
                    "width  = ^.width - 2*padding",
                    "top    > ^.top   + padding",
                    "height > 100",
                    "height < 200",
                    "bottom < ^.bottom - padding")
        .WeakConstraint("y = mouse_y");
    
    BentoInheritStart(B);
    
    C = BentoBox()
        .Constraint("width  > 60",
                    "width  < 120",
                    "left   > ^.left   + padding",
                    "right  < ^.right  - padding",
                    "top    = ^.top    + padding",
                    "bottom = ^.bottom - padding")
        .WeakConstraint("x = mouse_x");
    
    BentoInheritEnd();
BentoInheritEnd();

A.Instantiate();

A.DrawWireframe();
B.DrawWireframe();
C.DrawWireframe();
