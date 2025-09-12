#import "Remap_Context"(VERBOSE=false);

#load "../Core/core.jai";
#load "../Renderer/renderer.jai";
#load "game.jai";

Module_ID :: ModuleID.Game;

g_context : #Context;

g_module := GameModule.{
    Initialize=InitializeGame,
    Shutdown=ShutdownGame,
    OnModuleReload=OnModuleReload,
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

OnModuleReload :: (id : ModuleID) {
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
    g_context = remap_context();
    push_context,defer_pop g_context;
}

ShutdownGame :: () {
    push_context,defer_pop g_context;
}

DestroyWorld :: (world : *World) {
    push_context,defer_pop g_context;
}

UpdateWorld :: (world : *World) {
    push_context,defer_pop g_context;
}

SubmitToRenderer :: (world : *World) {
    push_context,defer_pop g_context;
}
