AssetsWorkspaceBuildInfo :: struct {
    generated_asset_code := false;
    asset_types : [..]*Type_Info_Struct;
}

g_assets_workspace_build_info : [Max_Workspaces]AssetsWorkspaceBuildInfo;

HandleDeclarationForAsset :: (workspace : Workspace, decl : *Code_Declaration) {
    using _ := *g_assets_workspace_build_info[workspace];

    has_asset_note := false;
    for note : decl.notes {
        if note.text == "Asset" {
            has_asset_note = true;
        }
    }

    // @Todo: do some typechecking
    if has_asset_note && decl.expression && decl.expression.kind == .STRUCT {
        struct_type := cast(*Code_Struct, decl.expression).defined_type;
        array_add(*asset_types, struct_type);
    }
}

GenerateAssetCode :: (workspace : Workspace) {
    #import "Sort";

    using _ := *g_assets_workspace_build_info[workspace];

    if generated_asset_code {
        return;
    }

    defer generated_asset_code = true;

    quick_sort(asset_types, (a, b) => compare_strings(a.name, b.name));

    builder : String_Builder;
    print_to_builder(*builder, "Asset_Types :: Type.[\n");
    for asset_types {
        print_to_builder(*builder, "    %,\n", it.name);
    }
    print_to_builder(*builder, "];\n");

    result := builder_to_string(*builder);
    add_build_string(result, workspace);
}
