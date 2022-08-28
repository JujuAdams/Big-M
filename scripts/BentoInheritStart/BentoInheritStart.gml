/// @param parent

function BentoInheritStart(_parent)
{
    array_push(global.__bentoInheritingStack, global.__bentoInheritingParent);
    global.__bentoInheritingParent = _parent;
}