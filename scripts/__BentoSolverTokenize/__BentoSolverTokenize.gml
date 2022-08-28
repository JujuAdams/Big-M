/// @param inString

function __BentoSolverTokenize(_inString)
{
    var _tokenArray = [];
    
    var _buffer = buffer_create(string_byte_length(_inString)+1, buffer_fixed, 1);
    buffer_poke(_buffer, 0, buffer_text, _inString);
    
    var _tokenStart      = 0;
    var _tokenType       = undefined; //0 = number, 1 = symbol, 2 = text
    var _newTokenType    = undefined;
    var _scanForNewToken = false;
    
    
    repeat(buffer_get_size(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte <= 32)
        {
            _newTokenType = undefined;
        }
        else switch(_tokenType)
        {
            case 0: //number
                if (((_byte >= 48) && (_byte <= 57)) || (_byte == 46))
                {
                    //Still in a number
                }
                else
                {
                    _scanForNewToken = true;
                }
            break;
            
            case 1: //symbol
                switch(_byte)
                {
                    case 42: //Multiply
                    case 43: //Plus
                    case 45: //Minus
                    case 47: //Divide
                    case 60: //Less than
                    case 61: //Equals
                    case 62: //Greater than
                        //Still in a symbol
                    break;
                    
                    default:
                        _scanForNewToken = true;
                    break;
                }
            break;
            
            case 2: //text
                if (((_byte >= 64) && (_byte <=  90))  //Upper case
                ||  ((_byte >= 97) && (_byte <= 122)) //Lower case
                ||  (_byte == 94) //Caret
                ||  (_byte == 95)) //Underscore
                {
                    //Still in a string
                }
                else
                {
                    _scanForNewToken = true;
                }
            break;
            
            case undefined:
                _scanForNewToken = true;
            break;
            
            default:
                show_error("Unhandled token type \"" + string(_tokenType) + "\"\n ", true);
            break;
        }
        
        if (_scanForNewToken)
        {
            _scanForNewToken = false;
            
            switch(_byte)
            {
                case 42: //Multiply
                case 43: //Plus
                case 45: //Minus
                case 46: //Dot
                case 47: //Divide
                    _newTokenType = 1; //Symbol
                break;
                
                case 48: //0
                case 49: //1
                case 50: //2
                case 51: //3
                case 52: //4
                case 53: //5
                case 54: //6
                case 55: //7
                case 56: //8
                case 57: //9
                    _newTokenType = 0; //Number
                break;
                
                case 60: //Less than
                case 61: //Equals
                case 62: //Greater than
                    _newTokenType = 1; //Symbol
                break;
                
                default:
                    if (((_byte >= 65) && (_byte <=  90))  //Upper case
                    ||  ((_byte >= 97) && (_byte <= 122)) //Lower case
                    ||  (_byte == 94) //Caret
                    ||  (_byte == 95)) //Underscore
                    {
                        _newTokenType = 2; //Text
                    }
                    else
                    {
                        show_error("Unhandled leading character, byte = " + string(_byte) + "\n ", true);
                    }
                break;
            }
        }
        
        if (_newTokenType != _tokenType)
        {
            if (_tokenType != undefined)
            {
                var _tokenEnd = buffer_tell(_buffer)-1;
                if (_tokenStart < _tokenEnd)
                {
                    var _old = buffer_peek(_buffer, _tokenEnd, buffer_u8);
                    buffer_poke(_buffer, _tokenEnd, buffer_u8, 0x00);
                    buffer_seek(_buffer, buffer_seek_start, _tokenStart);
                    var _string = buffer_read(_buffer, buffer_string);
                    buffer_poke(_buffer, _tokenEnd, buffer_u8, _old);
                    
                    switch(_tokenType)
                    {
                        case 0: //number
                            try
                            {
                                var _number = real(_string);
                            }
                            catch(_error)
                            {
                                show_error("Could not convert \"" + string(_string) + "\" to a number\n ", true);
                            }
                            
                            array_push(_tokenArray, 0, _number);
                        break;
                        
                        case 1: //symbol
                            switch(_string)
                            {
                                case ".":
                                case "+":
                                case "-":
                                case "*":
                                case "/":
                                case "=":
                                case "==":
                                case "<":
                                case "<=":
                                case ">":
                                case ">=":
                                break;
                                
                                default:
                                    show_error("\"" + string(_string) + "\" not recognised as a symbol\n ", true);
                                break;
                            }
                            
                            array_push(_tokenArray, 1, _string);
                        break;
                        
                        case 2: //text
                            array_push(_tokenArray, 2, _string);
                        break;
                    }
                }
            }
            
            _tokenStart = buffer_tell(_buffer)-1;
            _tokenType = _newTokenType;
        }
    }
    
    buffer_delete(_buffer);
    
    return _tokenArray;
}