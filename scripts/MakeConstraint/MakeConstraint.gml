#macro MAKE_CONSTRAINT_NO_STRICT_INEQUALITIES  true

function MakeConstraint()
{
    var _result = {
        op: "=",
        const: 0,
    };
    
    static __structAddFunc = function(_struct, _variable, _delta)
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
    
    var _reverse = 1;
    
    var _i = 0;
    repeat(argument_count)
    {
        var _term = argument[_i];
        switch(_term)
        {
            case "<=":
            case "<":
            case "=":
            case ">=":
            case ">":
                if (MAKE_CONSTRAINT_NO_STRICT_INEQUALITIES)
                {
                    if (_term == "<") _term = "<=";
                    if (_term == ">") _term = ">=";
                }
                
                _result.op = _term;
                _reverse = -1;
            break;
            
            default:
                if (is_numeric(_term))
                {
                    _result.const -= _term*_reverse;
                }
                else
                {
                    var _dotPos     = string_pos(".", _term);
                    var _preString  = string_copy(  _term, 1, _dotPos);
                    var _postString = string_delete(_term, 1, _dotPos);
                    
                    switch(_postString)
                    {
                        case "width":
                            __structAddFunc(_result, _preString + "left",  -_reverse);
                            __structAddFunc(_result, _preString + "right",  _reverse);
                        break;
                        
                        case "height":
                            __structAddFunc(_result, _preString + "top",    -_reverse);
                            __structAddFunc(_result, _preString + "bottom",  _reverse);
                        break;
                        
                        case "x":
                            __structAddFunc(_result, _preString + "left",  0.5*_reverse);
                            __structAddFunc(_result, _preString + "right", 0.5*_reverse);
                        break;
                        
                        case "y":
                            __structAddFunc(_result, _preString + "top",    0.5*_reverse);
                            __structAddFunc(_result, _preString + "bottom", 0.5*_reverse);
                        break;
                        
                        default:
                            _result[$ _term] = _reverse;
                        break;
                    }
                }
            break;
        }
        
        ++_i;
    }
    
    return _result;
}