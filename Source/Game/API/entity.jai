EntityAPI :: struct {
    all_vtables : [Entity_Types.count]EntityVTable;

    #place all_vtables;

    #insert -> string {
        builder : String_Builder;

        for Entity_Types {
VTable :: #string Jai
%1_vtable : struct {
    OnSpawn : (world : *World, entity : *%1);
    OnDespawn : (world : *World, entity : *%1);
    OnEditorUpdate : (world : *World, entity : *%1);
    OnDebugDraw : (world : *World, entity : *%1);
    OnAttach : (world : *World, entity : *%1);
    OnDetach : (world : *World, entity : *%1);
    GetEditorIcon : (world : *World, entity : *%1) -> *Asset(Texture2D);
}
Jai
            print_to_builder(*builder, VTable, it);
        }

        return builder_to_string(*builder);
    }
}

EntityVTable :: struct {
    OnSpawn : (world : *World, entity : *Entity);
    OnDespawn : (world : *World, entity : *Entity);
    OnEditorUpdate : (world : *World, entity : *Entity);
    OnDebugDraw : (world : *World, entity : *Entity);
    OnAttach : (world : *World, entity : *Entity);
    OnDetach : (world : *World, entity : *Entity);
    GetEditorIcon : (world : *World, entity : *Entity) -> *Asset(Texture2D);
}

Entity_Types :: Type.[];

Entity :: struct {
    guid : [2]u64;
    local_position : Vector3;
    local_rotation : Quaternion;
    local_scale : Vector3;
}
