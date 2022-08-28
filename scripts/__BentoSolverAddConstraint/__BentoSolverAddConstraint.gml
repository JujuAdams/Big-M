/// @param context
/// @param string
/// @param strength

function __BentoSolverAddConstraint(_context, _string, _strength)
{
    with(_context)
    {
        var _compressedTokens = __BentoSolverCompressTokens(_context, __BentoSolverTokenize(_string));
        if (!is_infinity(_strength)) _compressedTokens.weight = _strength;
        array_push(global.__bentoSystemConstraints, _compressedTokens);
    }
}