/// @param array
/// @param constantStruct

function ParseExpressionArray(_array, _constantStruct)
{
    var _i = 0;
    repeat(array_length(_array))
    {
        _array[@ _i] = ParseExpression(_array[_i], _constantStruct);
        ++_i;
    }
}