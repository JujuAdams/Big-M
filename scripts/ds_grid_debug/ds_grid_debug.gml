/// @param grid

function ds_grid_debug(_grid)
{
    var _string = "";
    
    var _width  = ds_grid_width(_grid);
    var _height = ds_grid_height(_grid);
    
    var _y = 0;
    repeat(_height)
    {
        var _x = 0;
        repeat(_width)
        {
            _string += string_format(_grid[# _x, _y], 4, 2);
            if (_x < _width-1) _string += ",";
            ++_x;
        }
        
        if (_y < _height-1) _string += "\n";
        ++_y;
    }
    
    show_debug_message(_string);
}