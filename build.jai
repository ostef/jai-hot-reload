#import "Basic";
#import "String";
#import "File";
#import "File_Utilities";
#import "Compiler";

#load "Source/Core/build.jai";
#load "Source/Game/build.jai";
#load "Source/Renderer/build.jai";

Max_Workspaces :: 20;

#if OS == {
case .WINDOWS; Lib_Ext :: "dll";
case .LINUX;   Lib_Ext :: "so";
case .MACOS;   Lib_Ext :: "dylib";
}

Renderer_Lib_File :: #run sprint("Libs/Renderer.%", Lib_Ext);
Game_Lib_File     :: #run sprint("Libs/Game.%", Lib_Ext);

BuildModule :: (name : string, source_file : string, handle_compiler_message : (*Message) = null) {
    compilation_failed := false;

    start_time := current_time_monotonic();
    defer if compilation_failed {
        log_error("Compilation failed for module %", name);
    } else {
        end_time := current_time_monotonic();
        total_time := end_time - start_time;
        print("  Compiled module % in % seconds\n", name, to_float64_seconds(total_time));
    }

    ws := compiler_create_workspace(name);

    options := get_build_options(ws);
    options.output_type = .DYNAMIC_LIBRARY;
    make_directory_if_it_does_not_exist("Libs");
    options.output_path = "Libs";
    options.output_executable_name = name;
    options.import_path = get_build_options().import_path;
    options.Commonly_Propagated = get_build_options().Commonly_Propagated;
    options.write_added_strings = true;
    options.stack_trace = true;
    options.text_output_flags = 0;
    set_build_options(options, ws);

    compiler_begin_intercept(ws);

    add_build_file(source_file, ws);

    while true {
        msg := compiler_wait_for_message();
        if handle_compiler_message && msg.workspace == ws {
            handle_compiler_message(msg);
        }

        if msg.kind == .COMPLETE {
            complete := cast(*Message_Complete, msg);
            if complete.error_code != .NONE {
                compilation_failed = true;
            }

            break;
        }
    }

    compiler_end_intercept(ws);
}

BuildCoreLoader :: () {
    compilation_failed := false;

    start_time := current_time_monotonic();
    defer if compilation_failed {
        log_error("Compilation failed for loader");
    } else {
        end_time := current_time_monotonic();
        total_time := end_time - start_time;
        print("  Compiled loader in % seconds\n", to_float64_seconds(total_time));
    }

    ws := compiler_create_workspace("Core");

    options := get_build_options(ws);
    options.output_type = .EXECUTABLE;
    options.output_executable_name = "main";
    options.import_path = get_build_options().import_path;
    options.Commonly_Propagated = get_build_options().Commonly_Propagated;
    options.write_added_strings = true;
    options.stack_trace = true;
    options.text_output_flags = 0;
    set_build_options(options, ws);

    compiler_begin_intercept(ws);

    add_build_file("Source/main.jai", ws);

    while true {
        msg := compiler_wait_for_message();
        if msg.workspace == ws {
            HandleCompilerMessageForCore(msg);
        }

        if msg.kind == .COMPLETE {
            complete := cast(*Message_Complete, msg);
            if complete.error_code != .NONE {
                compilation_failed = true;
            }

            break;
        }
    }

    compiler_end_intercept(ws);
}

CompareFileTimes :: (a : string, b : string) -> bool {
    a_modtime, _, a_exists := file_modtime_and_size(a);
    if !a_exists {
        return true;
    }

    if !is_directory(b) {
        b_modtime, _, b_exists := file_modtime_and_size(b);
        if !b_exists {
            return true;
        }

        return a_modtime < b_modtime;
    } else {
        files := file_list(b, recursive=true);
        for files {
            modtime := file_modtime_and_size(it);
            if a_modtime < modtime {
                return true;
            }
        }

        return false;
    }
}

Build :: () {
    auto_detect : bool;
    build_core : bool;
    build_renderer : bool;
    build_game : bool;

    start_time := current_time_monotonic();
    defer if build_core || build_renderer || build_game {
        end_time := current_time_monotonic();
        total_time := end_time - start_time;
        print("  Total time: % seconds\n", to_float64_seconds(total_time));
    }

    set_build_options_dc(.{do_output=false, write_added_strings=false});

    args := get_build_options().compile_time_command_line;
    arg_index := 0;

    while arg_index < args.count {
        defer arg_index += 1;

        if args[arg_index] == {
        case "-auto";
            auto_detect = true;
        case "-core";
            build_core = true;
        case "-renderer";
            build_renderer = true;
        case "-game";
            build_game = true;
        case "-all";
            build_core = true;
            build_renderer = true;
            build_game = true;
        case;
            log_error("Unknown argument '%'.", args[arg_index]);
            exit(1);
        }
    }

    if !auto_detect && !build_core && !build_renderer && !build_game {
        log_error("Nothing to build");
        exit(1);
    }

    // Compare file times so we know if we should rebuild a module
    if auto_detect {
        build_core     ||= CompareFileTimes("main", "Source/Core") || CompareFileTimes("main", "Source/main.jai");
        build_renderer ||= CompareFileTimes(Renderer_Lib_File, "Source/Renderer");
        build_game     ||= CompareFileTimes(Game_Lib_File, "Source/Game");

        for Renderer_Module_Dependencies {
            build_renderer ||= CompareFileTimes(Renderer_Lib_File, it);
        }
        for Game_Module_Dependencies {
            build_game ||= CompareFileTimes(Game_Lib_File, it);
        }
    }

    if build_core {
        BuildCoreLoader();
    }
    if build_renderer {
        BuildModule("Renderer", "Source/Renderer/renderer.jai", HandleCompilerMessageForRenderer);
    }
    if build_game {
        BuildModule("Game", "Source/Game/game.jai", HandleCompilerMessageForGame);
    }
}

#run,stallable Build();
