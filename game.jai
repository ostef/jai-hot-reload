#import "Basic";
#import "SDL";
#import "Default_Allocator";
#import "Remap_Context"(VERBOSE=false);

#load "core.jai";

// You can use @GlobalPersistent note, with an optional identifier to add a global state
// This is convenient because you don't have to modify and maintain a centralized place to add global state

GlobalPersistent :: struct {
    identifier : string;
    type : Type;
}

#placeholder Global_Persistent;

GlobalState :: struct {
    #insert -> string {
        builder : String_Builder;

        for Global_Persistent {
            if it.identifier {
                print_to_builder(*builder, "% : %;\n", it.identifier, it.type);
            } else {
                print_to_builder(*builder, "using _ : %;\n", it.type);
            }
        }

        return builder_to_string(*builder);
    }
}

// @Hack
// When declaring g_state directly we have a circular dependency
// We need to wait on GlobalState first, hence the #insert
#insert -> string {
    state : *GlobalState; // Make sure the compiler understands that we want GlobalState to be typechecked before

    return "using g_state : *GlobalState;";
}

g_context : #Context;

EditorState :: struct {
    // Blah
} @GlobalPersistent(g_editor)

GameState :: struct {
    g_window : *SDL_Window;
} @GlobalPersistent

RendererState :: struct {
    // Blah
} @GlobalPersistent

AssetsState :: struct {
    // Blah
} @GlobalPersistent

// You get the idea...

// Only called once, not called when reloaded
Initialize :: () -> EngineModuleResult {
    g_context = remap_context();
    push_context,defer_pop g_context;

    g_state.g_window = SDL_CreateWindow("Hot Reloaded Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 1920, 1080, 0);

    log("Initialized game");

    return .{};
}

// Only called once, not called when unloaded
Shutdown :: () {
    push_context,defer_pop g_context;

    log("Shutting down");

    SDL_DestroyWindow(g_state.g_window);
}

OnReload :: () {
    push_context,defer_pop g_context;
}

MainLoop :: () -> EngineModuleResult {
    push_context,defer_pop g_context;

    should_quit : bool;
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        if event.type == SDL_QUIT {
            should_quit = true;
        }
    }

    return .{should_quit=should_quit};
}

#program_export
ModuleHandshake :: (module : *EngineModule, state : **void, state_size : *s64) -> bool #c_call {
    push_context {
        module.initialize = Initialize;
        module.shutdown = Shutdown;
        module.on_reload = OnReload;
        module.main_loop = MainLoop;

        if !state.* {
            state.* = New(GlobalState);
            state_size.* = size_of(GlobalState);
        } else if state_size.* != size_of(GlobalState) {
            log_error("Detected a change in the memory layout of the game");
            return false;
        }

        g_state = state.*;

        return true;
    }
}
