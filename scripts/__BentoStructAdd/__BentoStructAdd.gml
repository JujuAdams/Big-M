/// @param struct
/// @param variable
/// @param delta

function __BentoStructAdd(_struct, _variable, _delta)
{
    if (variable_struct_exists(_struct, _variable))
    {
        _struct[$ _variable] += _delta;
    }
    else
    {
        _struct[$ _variable] = _delta;
    }
}
