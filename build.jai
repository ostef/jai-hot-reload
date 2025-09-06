#import "Basic";
#import "String";
#import "File";
#import "Compiler";

GlobalPersistent :: struct {
    identifier : string;
    type : *Type_Info_Struct;
}

g_global_persistent_generated : bool;
g_global_persistent : [..]GlobalPersistent;

HandleDeclarationForGlobalPersistent :: (decl : *Code_Declaration) {
    struct_type : *Type_Info_Struct;
    location := make_location(decl);
    if decl.expression && decl.expression.kind == .STRUCT {
        struct_type = cast(*Code_Struct, decl.expression).defined_type;
    } else {
        return;
    }

    for note : decl.notes {
        if starts_with(note.text, "GlobalPersistent") {
            str := advance(note.text, "GlobalPersistent".count);
            if str.count == 0 {
                array_add(*g_global_persistent, .{type=struct_type});
            } else {
                if str[0] != #char "(" || str[str.count - 1] != #char ")" {
                    compiler_report("Invalid @GlobalPersistent note", location);
                }

                advance(*str);
                str.count -= 1;

                array_add(*g_global_persistent, .{identifier=str, type=struct_type});
            }
        }
    }
}

GenerateGlobalPersistentCode :: (workspace : Workspace) {
    if g_global_persistent_generated {
        return;
    }

    defer g_global_persistent_generated = true;

    builder : String_Builder;
    print_to_builder(*builder, "Global_Persistent :: GlobalPersistent.[\n");
    for g_global_persistent {
        print_to_builder(*builder, "    .{identifier=\"%\", type=%},\n", it.identifier, get_type(it.type));
    }
    print_to_builder(*builder, "];\n");

    add_build_string(builder_to_string(*builder), workspace);
}

BuildGame :: () {
    ws := compiler_create_workspace("Game");

    options := get_build_options(ws);
    options.output_type = .DYNAMIC_LIBRARY;
    make_directory_if_it_does_not_exist("Libs");
    options.output_path = "Libs";
    options.output_executable_name = "game";
    options.import_path = get_build_options().import_path;
    options.Commonly_Propagated = get_build_options().Commonly_Propagated;
    options.write_added_strings = true;
    options.stack_trace = true;
    options.text_output_flags = 0;
    set_build_options(options, ws);

    compiler_begin_intercept(ws);

    add_build_file("game.jai", ws);

    while true {
        msg := compiler_wait_for_message();

        if msg.kind == {
        case .TYPECHECKED;
            typechecked := cast(*Message_Typechecked, msg);
            for typechecked.declarations {
                decl := it.expression;
                if !decl {
                    continue;
                }

                HandleDeclarationForGlobalPersistent(decl);
            }

        case .PHASE;
            phase := cast(*Message_Phase, msg);
            if phase.phase == .TYPECHECKED_ALL_WE_CAN {
                GenerateGlobalPersistentCode(msg.workspace);
            }
        case .COMPLETE;
            break;
        }
    }

    compiler_end_intercept(ws);
}

BuildLoader :: () {
    ws := compiler_create_workspace("Loader");

    options := get_build_options(ws);
    options.output_type = .EXECUTABLE;
    options.output_executable_name = "Game";
    options.import_path = get_build_options().import_path;
    options.Commonly_Propagated = get_build_options().Commonly_Propagated;
    options.write_added_strings = true;
    options.stack_trace = true;
    options.text_output_flags = 0;
    set_build_options(options, ws);

    compiler_begin_intercept(ws);

    add_build_file("loader.jai", ws);

    while true {
        msg := compiler_wait_for_message();

        if msg.kind == {
        case .COMPLETE;
            break;
        }
    }

    compiler_end_intercept(ws);
}

Build :: () {
    set_build_options_dc(.{do_output=false, write_added_strings=false});

    args := get_build_options().compile_time_command_line;
    arg_index := 0;

    build_loader : bool;
    build_game : bool;

    while arg_index < args.count {
        defer arg_index += 1;

        if args[arg_index] == {
        case "-loader";
            build_loader = true;
        case "-game";
            build_game = true;

        case;
            log_error("Unknown argument '%'.", args[arg_index]);
            exit(1);
        }
    }

    if build_loader {
        BuildLoader();
    }

    if build_game {
        BuildGame();
    }
}

#run,stallable Build();
