#load "API/core.jai";

Module_ID :: ModuleID.Core;

g_module := CoreModule.{
    base.Initialize=InitializeCore,
    base.Shutdown=ShutdownCore,
    base.MainLoop=CoreLoop,
    Quit=Quit,
    GetModule=GetModule,
    GetWindow=GetWindow,
    gfx.GetGfxContext=GetGfxContext,
    assets.GetAssets=GetAssets,
};

ModuleHandshake :: (core : *CoreModule) -> *Module #c_call {
    return *g_module;
}

g_window : *SDL_Window;
g_gfx_context : GfxContext;
g_assets : Assets;

GetModule :: inline (id : ModuleID) -> *Module {
    return g_modules[id];
}

GetWindow :: inline () -> *SDL_Window {
    return g_window;
}

GetGfxContext :: inline () -> *GfxContext {
    return *g_gfx_context;
}

GetAssets :: inline () -> *Assets {
    return *g_assets;
}

InitializeCore :: () {
    g_window = SDL_CreateWindow("Hot Reload", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 1600, 900, 0);
}

ShutdownCore :: () {
    SDL_DestroyWindow(g_window);
}

CoreLoop :: () {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        for g_modules {
            if it && it.OnEvent {
                it.OnEvent(event);
            }
        }

        if event.type == SDL_QUIT {
            Quit();
        }
    }
}

Quit :: () {
    g_quit = true;
}
