EntityWorkspaceBuildInfo :: struct {
    generated_entity_code := false;
    entity_types : [..]*Type_Info_Struct;
}

g_entity_workspace_build_info : [Max_Workspaces]EntityWorkspaceBuildInfo;

HandleDeclarationForEntity :: (workspace : Workspace, decl : *Code_Declaration) {
    using _ := *g_entity_workspace_build_info[workspace];

    has_entity_note := false;
    for note : decl.notes {
        if note.text == "Entity" {
            has_entity_note = true;
        }
    }

    // @Todo: do some typechecking
    if has_entity_note && decl.expression && decl.expression.kind == .STRUCT {
        struct_type := cast(*Code_Struct, decl.expression).defined_type;
        array_add(*entity_types, struct_type);
    }
}

GenerateEntityCode :: (workspace : Workspace) {
    #import "Sort";

    using _ := *g_entity_workspace_build_info[workspace];

    if generated_entity_code {
        return;
    }

    defer generated_entity_code = true;

    quick_sort(entity_types, (a, b) => compare_strings(a.name, b.name));

    builder : String_Builder;
    print_to_builder(*builder, "Entity_Types :: Type.[\n");
    for entity_types {
        print_to_builder(*builder, "    %,\n", it.name);
    }
    print_to_builder(*builder, "];\n");

    result := builder_to_string(*builder);
    add_build_string(result, workspace);
}
