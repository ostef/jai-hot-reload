#import "Basic";
#import "SDL";

#load "gfx.jai";
#load "assets.jai";

ModuleID :: enum {
    Core;
    Renderer;
    Game;
}

Num_Modules :: #run type_info(ModuleID).values.count;

Module :: struct {
    Initialize : ();
    Shutdown : ();
    MainLoop : ();
    OnEvent : (event : SDL_Event);
    SaveState : () -> []u8;
    LoadState : (state : []u8);

    OnModuleUnload : (id : ModuleID);
    OnModuleLoad : (id : ModuleID);
}

ModuleHandshakeProc :: #type (core : *CoreModule) -> *Module #c_call;

CoreModule :: struct {
    #as using _ : Module;

    Quit : ();
    GetModule : (id : ModuleID) -> *Module;
    GetWindow : () -> *SDL_Window;
    using gfx : GfxAPI;
    using assets : AssetsAPI;
}

#if Module_ID != .Core {

g_core : *CoreModule;

Quit :: inline () {
    assert(g_core != null, "Core module is null");

    g_core.Quit();
}

GetModule :: inline (id : ModuleID) -> *Module {
    assert(g_core != null, "Core module is null");

    return g_core.GetModule(id);
}

GetWindow :: inline () -> *SDL_Window {
    assert(g_core != null, "Core module is null");

    return g_core.GetWindow();
}

GetGfxContext :: inline () -> *GfxContext {
    assert(g_core != null, "Core module is null");

    return g_core.GetGfxContext();
}

GetAssets :: inline () -> *Assets {
    assert(g_core != null, "Core module is null");

    return g_core.GetAssets();
}

}
