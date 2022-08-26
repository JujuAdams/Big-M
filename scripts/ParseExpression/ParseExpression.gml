/// @param string
/// @param constantStruct

function ParseExpression(_inString, _constantStruct)
{
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
    
    var _result = {};
    var _tokenArray = [];
    
    #region Tokenizer
    
    var _buffer = buffer_create(string_byte_length(_inString)+1, buffer_fixed, 1);
    buffer_poke(_buffer, 0, buffer_text, _inString);
    
    var _tokenStart      = 0;
    var _tokenType       = undefined; //0 = number, 1 = symbol, 2 = term
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
            case 0: //Number
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
            
            case 2: //term
                if (((_byte >= 64) && (_byte <=  90))  //Upper case
                ||  ((_byte >= 97) && (_byte <= 122)) //Lower case
                ||  (_byte == 46)) //Dot
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
                    ||  ((_byte >= 97) && (_byte <= 122))) //Lower case
                    {
                        _newTokenType = 2; //Term
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
                        case 0: //Number
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
                        
                        case 1: //Symbol
                            switch(_string)
                            {
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
                                    show_error("\"" + string(_string) + "\" not recognised as an operator\n ", true);
                                break;
                            }
                            
                            array_push(_tokenArray, 1, _string);
                        break;
                        
                        case 2: //Term
                            if (variable_struct_exists(_constantStruct, _string))
                            {
                                array_push(_tokenArray, 0, _constantStruct[$ _string]);
                            }
                            else
                            {
                                array_push(_tokenArray, 2, _string);
                            }
                        break;
                    }
                }
            }
            
            _tokenStart = buffer_tell(_buffer)-1;
            _tokenType = _newTokenType;
        }
    }
    
    buffer_delete(_buffer);
    
    #endregion
    
    
    
    #region Process tokens
    
    var _reverse = 1;
    
    var _nextPhraseRHS      = false;
    var _nextPhraseNegative = false;
    
    var _phraseTerm        = undefined;
    var _phraseCoefficient = 1;
    var _phraseLastOp      = undefined;
    var _phraseFlush       = false;
    
    var _i = 0;
    var _maxI = (array_length(_tokenArray) div 2)-1;
    repeat(array_length(_tokenArray) div 2)
    {
        var _tokenType = _tokenArray[_i  ]; //0 = number, 1 = symbol, 2 = term
        var _token     = _tokenArray[_i+1];
        
        switch(_tokenType)
        {
            case 0: //Number
                switch(_phraseLastOp)
                {
                    case "*":
                        _phraseCoefficient *= _token;
                    break;
                    
                    case "/":
                        _phraseCoefficient /= _token;
                    break;
                    
                    case undefined:
                        _phraseCoefficient *= _token;
                    break;
                }
                
                _phraseLastOp = undefined;
            break;
            
            case 1: //Symbol
                switch(_token)
                {
                    case "+":
                        _phraseFlush = true;
                    break;
                    
                    case "-":
                        _nextPhraseNegative = true;
                        _phraseFlush = true;
                    break;
                    
                    case "*":
                    case "/":
                        _phraseLastOp = _token;
                    break;
                    
                    case "=":
                    case "==":
                    case "<":
                    case "<=":
                    case ">":
                    case ">=":
                        if (variable_struct_exists(_result, "op"))
                        {
                            show_error("Expression has more than one operator\n ", true);
                        }
                        
                        _result.op = _token;
                        _nextPhraseRHS = true;
                        _phraseFlush = true;
                    break;
                    
                    default:
                        show_error("\"" + string(_string) + "\" not recognised as an operator\n ", true);
                    break;
                }
            break;
            
            case 2: //Term
                if (_phraseLastOp == "/")
                {
                    show_error("Cannot use reciprocal variables\n ", true);
                }
                else if (_phraseTerm != undefined)
                {
                    show_error("Phrases cannot have more than one term\n ", true);
                }
                else
                {
                    _phraseTerm = _token;
                    _phraseLastOp = undefined;
                }
            break;
        }
        
        if (_phraseFlush || (_i == _maxI))
        {
            _phraseCoefficient *= _reverse;
            
            if (_phraseTerm != undefined)
            {
                var _dotPos     = string_pos(".", _phraseTerm);
                var _preString  = string_copy(  _phraseTerm, 1, _dotPos);
                var _postString = string_delete(_phraseTerm, 1, _dotPos);
                
                switch(_postString)
                {
                    case "width":
                        __structAddFunc(_result, _preString + "left",  -_phraseCoefficient);
                        __structAddFunc(_result, _preString + "right",  _phraseCoefficient);
                    break;
                    
                    case "height":
                        __structAddFunc(_result, _preString + "top",    -_phraseCoefficient);
                        __structAddFunc(_result, _preString + "bottom",  _phraseCoefficient);
                    break;
                    
                    case "x":
                        __structAddFunc(_result, _preString + "left",  0.5*_phraseCoefficient);
                        __structAddFunc(_result, _preString + "right", 0.5*_phraseCoefficient);
                    break;
                    
                    case "y":
                        __structAddFunc(_result, _preString + "top",    0.5*_phraseCoefficient);
                        __structAddFunc(_result, _preString + "bottom", 0.5*_phraseCoefficient);
                    break;
                    
                    default:
                        __structAddFunc(_result, _phraseTerm, _phraseCoefficient);
                    break;
                }
            }
            else
            {
                __structAddFunc(_result, "const", -_phraseCoefficient);
            }
            
            _phraseTerm        = undefined;
            _phraseCoefficient = 1;
            
            if (_nextPhraseNegative)
            {
                _nextPhraseNegative = false;
                _phraseCoefficient = -1;
            }
            
            if (_nextPhraseRHS)
            {
                _nextPhraseRHS = false;
                _reverse = -1;
            }
        }
        
        _i += 2;
    }
    
    #endregion
    
    
    
    return _result;
}