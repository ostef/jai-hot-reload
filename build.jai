#import "Basic";
#import "String";
#import "File";
#import "Compiler";

BuildModule :: (name : string, source_file : string, handle_compiler_message : (*Message)) {
    start_time := current_time_monotonic();
    defer {
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
            break;
        }
    }

    compiler_end_intercept(ws);
}

BuildCoreLoader :: () {
    start_time := current_time_monotonic();
    defer {
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
        // if msg.workspace == ws {
        //     CoreHandleCompilerMessage(msg);
        // }

        if msg.kind == .COMPLETE {
            break;
        }
    }

    compiler_end_intercept(ws);
}

Build :: () {
    start_time := current_time_monotonic();
    defer {
        end_time := current_time_monotonic();
        total_time := end_time - start_time;
        print("  Total time: % seconds\n", to_float64_seconds(total_time));
    }

    set_build_options_dc(.{do_output=false, write_added_strings=false});

    args := get_build_options().compile_time_command_line;
    arg_index := 0;

    build_core : bool;
    build_renderer : bool;
    build_game : bool;

    while arg_index < args.count {
        defer arg_index += 1;

        if args[arg_index] == {
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

    if !build_core && !build_renderer && !build_game {
        log_error("Nothing to build");
        exit(1);
    }

    if build_core {
        BuildCoreLoader();
    }
    if build_renderer {
        BuildModule("Renderer", "Source/Renderer/renderer.jai", null);
    }
    if build_game {
        BuildModule("Game", "Source/Game/game.jai", null);
    }
}

#run,stallable Build();
