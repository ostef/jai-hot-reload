Component_Types :: Type.[];

ComponentAPI :: struct {
    all_vtables : [Component_Types.count]ComponentVTable;

    #place all_vtables;

    #insert -> string {
        builder : String_Builder;

        for Component_Types {
VTable :: #string Jai
%1_vtable : struct {
    OnCreate : (world : *World, entity : *Entity, component : *%1);
    OnDestroy : (world : *World, entity : *Entity, component : *%1);
    OnEditorUpdate : (world : *World, entity : *Entity, component : *%1);
    OnDebugDraw : (world : *World, entity : *Entity, component : *%1);
    GetEditorIcon : (world : *World, entity : *Entity, component : *%1) -> *Asset(Texture2D);
}
Jai
            print_to_builder(*builder, VTable, it);
        }

        return builder_to_string(*builder);
    }
}

ComponentVTable :: struct {
    OnCreate : (world : *World, entity : *Entity, component : *Component);
    OnDestroy : (world : *World, entity : *Entity, component : *Component);
    OnEditorUpdate : (world : *World, entity : *Entity, component : *Component);
    OnDebugDraw : (world : *World, entity : *Entity, component : *Component);
    GetEditorIcon : (world : *World, entity : *Entity, component : *Component) -> *Asset(Texture2D);
}

Component :: struct {
}
