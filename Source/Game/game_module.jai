#import "Remap_Context"(VERBOSE=false);

#load "../Core/core.jai";
#load "../Renderer/renderer.jai";
#load "game.jai";

Module_ID :: ModuleID.Game;

g_context : #Context;

g_module := GameModule.{
    Initialize=InitializeGame,
    Shutdown=ShutdownGame,
    MainLoop=GameLoop,
    SaveState=SaveState,
    LoadState=LoadState,
    OnModuleLoad=OnModuleLoad,
    OnModuleUnload=OnModuleUnload,
    world.UpdateWorld=UpdateWorld,
    world.SubmitToRenderer=SubmitToRenderer,
};

OnModuleUnload :: (id : ModuleID) {
    push_context,defer_pop g_context;

    if id == {
    case .Core; assert(false, "Cannot unload core module");
    case .Renderer; g_renderer = null;
    }
}

OnModuleLoad :: (id : ModuleID) {
    if id == Module_ID {
        g_context = remap_context();
    }

    push_context,defer_pop g_context;

    if id == {
    case .Core; assert(false, "Cannot reload core module");
    case .Renderer; g_renderer = xx GetModule(.Renderer);
    }
}

#program_export
ModuleHandshake :: (core : *CoreModule) -> *Module #c_call {
    push_context,defer_pop;

    g_core = core;
    g_renderer = xx GetModule(.Renderer);
    return *g_module;
}

InitializeGame :: () {
    push_context,defer_pop g_context;
}

ShutdownGame :: () {
    push_context,defer_pop g_context;
}

DestroyWorld :: (world : *World) {
    push_context,defer_pop g_context;
}

GameLoop :: () {
    push_context,defer_pop g_context;
}

UpdateWorld :: (world : *World) {
    push_context,defer_pop g_context;
}

SubmitToRenderer :: (world : *World) {
    push_context,defer_pop g_context;
}

SaveState :: () -> []u8 {
    push_context,defer_pop g_context;

    return cast([]u8, sprint("Game State"));
}

LoadState :: (state : []u8) {
    push_context,defer_pop g_context;

    str := cast(string, state);
    assert(str == "Game State");
    free(str.data);
}
