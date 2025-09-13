EntityAPI :: struct {
    all_vtables : [Entity_Types.count]EntityVTable;

    #place all_vtables;

    #insert -> string {
        builder : String_Builder;

        for Entity_Types {
            print_to_builder(*builder, "%1_vtable : EntityVTable(%1);\n", it);
        }

        return builder_to_string(*builder);
    }
}

Entity :: struct {
    guid : [2]u64;
    local_position : Vector3;
    local_rotation : Quaternion;
    local_scale : Vector3;
}

EntityVTable :: struct($T : Type = Entity) {
    OnSpawn : (world : *World, entity : *T);
    OnDespawn : (world : *World, entity : *T);
    OnEditorUpdate : (world : *World, entity : *T);
    OnDebugDraw : (world : *World, entity : *T);
    OnAttach : (world : *World, entity : *T);
    OnDetach : (world : *World, entity : *T);
    GetEditorIcon : (world : *World, entity : *T) -> *Asset(Texture2D);
}

SomeEntity :: struct {
    #as using _ : Entity;

    some_texture : *Asset(Texture2D);
} @Entity
