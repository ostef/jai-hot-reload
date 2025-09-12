#load "core.jai";

Module_ID :: ModuleID.Editor;

#program_export
InitModule :: (core : *CoreModule, module : *EditorModule) -> bool #c_call {
    g_core = core;
    g_game = GetModule(.Game);

    return true;
}
