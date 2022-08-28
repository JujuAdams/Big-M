#macro BentoConstants  (global.__bentoConstantStruct)
global.__bentoConstantStruct = {};

global.__bentoInheritingParent = undefined;
global.__bentoInheritingStack  = [];

enum __BENTO_LAYOUT
{
    __FREE,
    __LIST_X,
    __LIST_Y,
    __GRID,
}

function BentoBox()
{
    return new __BentoClassBox();
}

global.__bentoBoxCounter = int64(0);

function __BentoClassBox(_name = undefined) constructor
{
    __bentoGlobalIndex = global.__bentoBoxCounter;
    ++global.__bentoBoxCounter;
    
    left   = 0;
    top    = 0;
    right  = 0;
    bottom = 0;
    
    __bentoLocalName        = _name ?? ("anon" + string(__bentoGlobalIndex));
    __bentoGlobalName       = __bentoLocalName;
    __bentoUniqueGlobalName = string(__bentoGlobalIndex);
    
    __bentoInstantiated          = false;
    __bentoChildren              = undefined;
    __bentoParent                = undefined;
    __bentoStrongConstraintArray = [];
    __bentoMidConstraintArray    = [];
    __bentoWeakConstraintArray   = [];
    
    __bentoLayout        = __BENTO_LAYOUT.__FREE;
    __bentoLayoutGutterX = 0;
    __bentoLayoutGutterY = 0;
    __bentoLayoutMaxX    = infinity;
    __bentoLayoutMaxY    = infinity;
    
    if (is_struct(global.__bentoInheritingParent))
    {
        ChildOf(global.__bentoInheritingParent);
    }
    
    static StrongConstraint = function()
    {
        switch(argument_count)
        {
            case 1: array_push(__bentoStrongConstraintArray, argument[0]); break;
            case 2: array_push(__bentoStrongConstraintArray, argument[0], argument[1]); break;
            case 3: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2]); break;
            case 4: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3]); break;
            case 5: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4]); break;
            case 6: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]); break;
            case 7: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6]); break;
            case 8: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7]); break;
            case 9: array_push(__bentoStrongConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8]); break;
            
            default:
                var _i = 0;
                repeat(argument_count)
                {
                    array_push(__bentoStrongConstraintArray, argument[_i]);
                    ++_i;
                }
            break;
        }
        
        return self;
    }
    
    static DrawWireframe = function()
    {
        draw_rectangle(left, top, right, bottom, true);
    }
    
    static Constraint = function()
    {
        switch(argument_count)
        {
            case 1: array_push(__bentoMidConstraintArray, argument[0]); break;
            case 2: array_push(__bentoMidConstraintArray, argument[0], argument[1]); break;
            case 3: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2]); break;
            case 4: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3]); break;
            case 5: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4]); break;
            case 6: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]); break;
            case 7: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6]); break;
            case 8: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7]); break;
            case 9: array_push(__bentoMidConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8]); break;
            
            default:
                var _i = 0;
                repeat(argument_count)
                {
                    array_push(__bentoMidConstraintArray, argument[_i]);
                    ++_i;
                }
            break;
        }
        
        return self;
    }
    
    static WeakConstraint = function()
    {
        switch(argument_count)
        {
            case 1: array_push(__bentoWeakConstraintArray, argument[0]); break;
            case 2: array_push(__bentoWeakConstraintArray, argument[0], argument[1]); break;
            case 3: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2]); break;
            case 4: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3]); break;
            case 5: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4]); break;
            case 6: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]); break;
            case 7: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6]); break;
            case 8: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7]); break;
            case 9: array_push(__bentoWeakConstraintArray, argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7], argument[8]); break;
            
            default:
                var _i = 0;
                repeat(argument_count)
                {
                    array_push(__bentoWeakConstraintArray, argument[_i]);
                    ++_i;
                }
            break;
        }
        
        return self;
    }
    
    static ChildOf = function(_parent)
    {
        __bentoParent = _parent;
        
        __bentoGlobalName       = _parent.__bentoGlobalName + "." + __bentoLocalName;
        __bentoUniqueGlobalName = _parent.__bentoUniqueGlobalName + "." + string(__bentoGlobalIndex);
        
        _parent.ChildAdd(self);
        return self;
    }
    
    static ChildAdd = function(_child)
    {
        if (!is_array(__bentoChildren)) __bentoChildren = [];
        array_push(__bentoChildren, _child);
        return self;
    }
    
    static LayoutFree = function()
    {
        __bentoLayout        = __BENTO_LAYOUT.__FREE;
        __bentoLayoutGutterX = 0;
        __bentoLayoutGutterY = 0;
        __bentoLayoutMaxX    = infinity;
        __bentoLayoutMaxY    = infinity;
        return self;
    }
    
    static LayoutListX = function(_gutter = 0)
    {
        __bentoLayout        = __BENTO_LAYOUT.__LIST_X;
        __bentoLayoutGutterX = 0;
        __bentoLayoutGutterY = _gutter;
        __bentoLayoutMaxX    = 1;
        __bentoLayoutMaxY    = infinity;
        return self;
    }
    
    static LayoutListY = function(_gutter = 0)
    {
        __bentoLayout        = __BENTO_LAYOUT.__LIST_Y;
        __bentoLayoutGutterX = _gutter;
        __bentoLayoutGutterY = 0;
        __bentoLayoutMaxX    = infinity;
        __bentoLayoutMaxY    = 1;
        return self;
    }
    
    static LayoutGrid = function(_gutterX = 0, _gutterY = 0, _maxX = infinity, _maxY = infinity)
    {
        __bentoLayout        = __BENTO_LAYOUT.__GRID;
        __bentoLayoutGutterX = _gutterX;
        __bentoLayoutGutterY = _gutterY;
        __bentoLayoutMaxX    = _maxX;
        __bentoLayoutMaxY    = _maxY;
        return self;
    }
    
    static Instantiate = function()
    {
        if (__bentoInstantiated) return self;
        __bentoInstantiated = true;
        
        if (__bentoParent != undefined) show_error("Cannot instantiate a Bento box with a parent\n ", true);
        
        __BentoSolverStart();
        __SetupSolver();
        __BentoSolverEnd();
        
        return self;
    }
    
    static __SetupSolver = function()
    {
        __BentoSolverMapBox(self);
        
        var _i = 0;
        repeat(array_length(__bentoStrongConstraintArray))
        {
            var _tokenArray = __BentoSolverAddConstraint(self, __bentoStrongConstraintArray[_i], infinity);
            ++_i;
        }
        
        var _i = 0;
        repeat(array_length(__bentoMidConstraintArray))
        {
            var _tokenArray = __BentoSolverAddConstraint(self, __bentoMidConstraintArray[_i], 100);
            ++_i;
        }
        
        var _i = 0;
        repeat(array_length(__bentoWeakConstraintArray))
        {
            var _tokenArray = __BentoSolverAddConstraint(self, __bentoWeakConstraintArray[_i], 1);
            ++_i;
        }
        
        if (is_array(__bentoChildren))
        {
            var _i = 0;
            repeat(array_length(__bentoChildren))
            {
                __bentoChildren[_i].__SetupSolver();
                ++_i;
            }
        }
    }
}
