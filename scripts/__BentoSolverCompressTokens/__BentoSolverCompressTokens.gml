/// @param context
/// @param tokenArray

function __BentoSolverCompressTokens(_context, _tokenArray)
{
    var _result = {};
    
    var _reverse            = 1;
    var _nextPhraseRHS      = false;
    var _nextPhraseNegative = false;
    
    var _phraseScopeStack   = [];
    var _phraseVariable     = undefined;
    var _phraseCoefficient  = 1;
    var _phraseLastOp       = undefined;
    var _phraseFlush        = false;
    
    var _i    = 0;
    var _maxI = array_length(_tokenArray)-2;
    repeat(array_length(_tokenArray) div 2)
    {
        var _tokenType = _tokenArray[_i  ]; //0 = number, 1 = symbol, 2 = variable
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
                    
                    default:
                        show_error("Unhandled operator \"" + string(_phraseLastOp) + "\" before number\n ", true);
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
                    case ".":
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
                        _phraseLastOp = undefined;
                    break;
                    
                    default:
                        show_error("\"" + string(_token) + "\" not recognised as an operator\n ", true);
                    break;
                }
            break;
            
            case 2: //Variable
                if (_phraseLastOp == "/")
                {
                    show_error("Cannot use reciprocal variables\n ", true);
                }
                
                if (_phraseVariable != undefined) array_push(_phraseScopeStack, _phraseVariable);
                _phraseVariable = _token;
                _phraseLastOp   = undefined;
            break;
        }
        
        if (_phraseFlush || (_i == _maxI))
        {
            _phraseFlush = false;
            
            _phraseCoefficient *= _reverse;
            
            if (_phraseVariable != undefined)
            {
                if (array_length(_phraseScopeStack) <= 0)
                {
                    if (variable_struct_exists(global.__bentoConstantStruct, _phraseVariable))
                    {
                        _phraseCoefficient *= global.__bentoConstantStruct[$ _phraseVariable];
                        _phraseVariable = undefined;
                    }
                }
            }
            
            if (_phraseVariable != undefined)
            {
                var _scope = _context;
                var _j = 0;
                repeat(array_length(_phraseScopeStack))
                {
                    var _scopeText = _phraseScopeStack[_j];
                    if ((_scopeText == "^") || (_scopeText == "parent"))
                    {
                        _scope = __bentoParent;
                    }
                    
                    --_j;
                }
                
                _scope = _scope.__bentoUniqueGlobalName;
                
                switch(_phraseVariable)
                {
                    case "width":
                        __BentoStructAdd(_result, _scope + ".left",  -_phraseCoefficient);
                        __BentoStructAdd(_result, _scope + ".right",  _phraseCoefficient);
                    break;
                    
                    case "height":
                        __BentoStructAdd(_result, _scope + ".top",    -_phraseCoefficient);
                        __BentoStructAdd(_result, _scope + ".bottom",  _phraseCoefficient);
                    break;
                    
                    case "x":
                        __BentoStructAdd(_result, _scope + ".left",  0.5*_phraseCoefficient);
                        __BentoStructAdd(_result, _scope + ".right", 0.5*_phraseCoefficient);
                    break;
                    
                    case "y":
                        __BentoStructAdd(_result, _scope + ".top",    0.5*_phraseCoefficient);
                        __BentoStructAdd(_result, _scope + ".bottom", 0.5*_phraseCoefficient);
                    break;
                    
                    case "^":
                        show_error("Missing variable after ^.\n ", true);
                    break;
                    
                    default:
                        __BentoStructAdd(_result, _scope + "." + _phraseVariable, _phraseCoefficient);
                    break;
                }
            }
            else
            {
                __BentoStructAdd(_result, "const", -_phraseCoefficient);
            }
            
            array_resize(_phraseScopeStack, 0);
            _phraseVariable    = undefined;
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
    
    return _result;
}