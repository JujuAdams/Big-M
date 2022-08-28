/// @param name
/// @param value

function BentoConstantSet(_name, _value)
{
    global.__bentoConstantStruct[$ _name] = _value;
    return _value;
}