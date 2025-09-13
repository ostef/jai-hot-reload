SomeEntity_vtable := EntityVTable(SomeEntity).{
};

InitializeEntityVTables :: (module : *GameModule) {
    #insert -> string {
        builder : String_Builder;

        for Entity_Types {
            print_to_builder(*builder, "module.entity.%1_vtable = %1_vtable;\n", it);
        }

        return builder_to_string(*builder);
    }
}
