#import "Bucket_Array";
#import "Hash_Table";

AssetsAPI :: struct {
    GetAssets : () -> *Assets;

    #insert -> string {
        builder : String_Builder;

        for Asset_Types {
            print_to_builder(*builder, "Load%1Asset : (name : string) -> *Asset(%1);\n", it);
        }

        return builder_to_string(*builder);
    }
}

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
    AssetType :: Asset(T);

    storage : Bucket_Array(AssetType, 20);
    assets_by_name : Table(string, *AssetType);
}

Asset :: struct(DataType : Type) {
    asset_name : string;
}

Texture2D :: struct {
    texture : GfxTexture;
} @Asset
