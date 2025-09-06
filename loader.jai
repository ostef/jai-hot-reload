#import "Basic";
#import "System";
#import "String";
#import "File";
#import "File_Utilities";
#import "File_Watcher";
#import "Default_Allocator";

#load "core.jai";

g_version : u32;
g_game_library : *void;
g_game_module : EngineModule;
g_game_module_load_failed : bool;
g_game_state : *void;
g_game_state_size : s64;
g_modules_watcher : File_Watcher;

Game_Lib_Name :: "game.dll";

ModulesChangeCallback :: (watcher : *File_Watcher(void), change : *File_Change, data : *void) {
    filename := path_filename(change.full_path);
    if filename == Game_Lib_Name {
        LoadGameModule();
    }
}

LoadGameModule :: () -> bool {
    g_game_module_load_failed = true;

    src_lib_path := tprint("Libs/%", Game_Lib_Name);
    dst_lib_path := tprint("Libs/%.%", g_version + 1, Game_Lib_Name);

    if !copy_file(src_lib_path, dst_lib_path) {
        log_error("Could not copy game library to versioned target");
        return false;
    }

    library := LoadLibraryA(to_c_string(dst_lib_path ,, temp));
    if !library {
        error := get_error_value();
        error_msg := get_error_string(error);
        log_error("Could not load %: %", dst_lib_path, error_msg);
        return false;
    }

    handshake := cast(EngineModuleHandshakeProc, GetProcAddress(library, "ModuleHandshake"));
    if !handshake {
        FreeLibrary(library);
        log_error("Could not load ModuleHandshake procedure");
        return false;
    }

    module : EngineModule;
    handshake_ok := handshake(*module, *g_game_state, *g_game_state_size);
    if !handshake_ok {
        FreeLibrary(library);
        log_error("Could not perform handshake");
        return false;
    }

    first_load := g_game_library == null;
    UnloadGameModule();

    log("Loaded game module %", dst_lib_path);
    log("Module state: %, size=%", g_game_state, g_game_state_size);

    g_game_module = module;
    g_game_library = library;
    g_version += 1;
    g_game_module_load_failed = false;

    if !first_load {
        g_game_module.on_reload();
    }

    return true;
}

UnloadGameModule :: () {
    if g_game_library {
        FreeLibrary(g_game_library);
        g_game_library = null;
        g_game_module = .{};

        lib_path := ifx g_version == 0
            then tprint("Libs/%", Game_Lib_Name)
            else tprint("Libs/%.%", g_version, Game_Lib_Name);
        if file_exists(lib_path) {
            file_delete(lib_path);
        }

        log("Unloaded game module %", lib_path);
    }
}

main :: () {
    exit_code : s32;
    defer exit(exit_code);

    if !LoadGameModule() {
        exit_code = 1;
        return;
    }

    defer UnloadGameModule();

    init_result := g_game_module.initialize();
    defer g_game_module.shutdown();

    if init_result.should_quit {
        exit_code = init_result.exit_code;
        return;
    }

    if init_result.should_reload {
        LoadGameModule();
    }

    init(*g_modules_watcher, ModulesChangeCallback);
    defer deinit(*g_modules_watcher);
    add_directories(*g_modules_watcher, "Libs");

    while true {
        process_changes(*g_modules_watcher);

        main_loop_result := g_game_module.main_loop();
        if main_loop_result.should_quit {
            exit_code = main_loop_result.exit_code;
            return;
        }

        if main_loop_result.should_reload {
            LoadGameModule();
        }
    }
}

Kernel32 :: #library,system "Kernel32";
LoadLibraryA :: (lpLibFilename : *u8) -> *void #foreign Kernel32;
GetProcAddress :: (hModule : *void, lpProcName : *u8) -> *void #foreign Kernel32;
FreeLibrary :: (hLibModule : *void) -> s32 #foreign Kernel32;
