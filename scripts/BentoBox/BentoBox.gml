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
    
    static DrawWireframe = function()
    {
        draw_rectangle(left, top, right, bottom, true);
    }
    
    static StrongConstraint = function(_constraintString)
    {
        array_push(__bentoStrongConstraintArray, _constraintString);
        return self;
    }
    
    static Constraint = function(_constraintString)
    {
        array_push(__bentoMidConstraintArray, _constraintString);
        return self;
    }
    
    static WeakConstraint = function(_constraintString)
    {
        array_push(__bentoWeakConstraintArray, _constraintString);
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
    
    
    
    #region Layout Setters
    
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
    
    static GetLayout = function()
    {
        var _layoutName = undefined;
        switch(__bentoLayout)
        {
            case __BENTO_LAYOUT.__FREE:   _layoutName = "free";   break;
            case __BENTO_LAYOUT.__LIST_X: _layoutName = "list x"; break;
            case __BENTO_LAYOUT.__LIST_Y: _layoutName = "list y"; break;
            case __BENTO_LAYOUT.__GRID:   _layoutName = "grid";   break;
            
            default:
            break;
        }
        
        return {
            layout:  _layoutName,
            gutterX: __bentoLayoutGutterX,
            gutterY: __bentoLayoutGutterY,
            maxX:    __bentoLayoutMaxX,
            maxY:    __bentoLayoutMaxY,
        };
    }
    
    #endregion
    
    
    
    #region LTRBXYWH Setters
    
    static SetLeft = function(_value)
    {
        left = _value;
        return self;
    }
    
    static SetTop = function(_value)
    {
        top = _value;
        return self;
    }
    
    static SetRight = function(_value)
    {
        right = _value;
        return self;
    }
    
    static SetBottom = function(_value)
    {
        bottom = _value;
        return self;
    }
    
    #endregion
    
    
    
    #region Private
    
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
    
    #endregion
}
