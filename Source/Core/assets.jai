AssetsAPI :: struct {
    GetAssets : () -> *Assets;

    #insert -> string {
        builder : String_Builder;

        for Asset_Types {
            print_to_builder(*builder, "load_%1_asset : (name : string) -> *Asset(%1);\n", it);
        }

        return builder_to_string(*builder);
    }
}

Asset_Types :: Type.[];

Assets :: struct {
    #insert -> string {
        builder : String_Builder;

        for Asset_Types {
            print_to_builder(*builder, "%1_database : AssetDatabase(%1);\n", it);
        }

        return builder_to_string(*builder);
    }
}

AssetDatabase :: struct(T : Type) {
}

Asset :: struct(DataType : Type) {
}

Texture2D :: struct {
    texture : GfxTexture;
}
