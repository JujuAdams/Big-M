function BentoInheritEnd()
{
    if (array_length(global.__bentoInheritingStack) <= 1)
    {
        global.__bentoInheritingParent = undefined;
        return;
    }
    
    array_pop(global.__bentoInheritingStack);
    global.__bentoInheritingParent = global.__bentoInheritingStack[array_length(global.__bentoInheritingStack)-1];
}