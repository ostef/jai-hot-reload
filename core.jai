// @Todo: detect when there are changes in the memory layout of the module. For now we just check the global state size
// This might be slow, although it's really just comparing types, and I am sure the compiler does much more than
// that in not much time, so maybe it is feasable to do. Idea on how to implement this: see get_type_table ;)

EngineModule :: struct {
    initialize : () -> EngineModuleResult;
    shutdown : ();
    on_reload : ();
    main_loop : () -> EngineModuleResult;
}

EngineModuleResult :: struct {
    should_quit : bool;
    should_reload : bool;
    exit_code : s32;
}

EngineModuleHandshakeProc :: #type (module : *EngineModule, state : **void, state_size : *s64) -> bool #c_call;
