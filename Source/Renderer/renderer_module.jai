#import "Remap_Context"(VERBOSE=false);

#load "../Core/core.jai";
#load "renderer.jai";

Module_ID :: ModuleID.Renderer;

g_module := RendererModule.{
    Initialize=InitializeRenderer,
    Shutdown=ShutdownRenderer,
    OnModuleReload=OnModuleReload,

    WaitForRenderThread=WaitForRenderThread,
    AddMeshToRender=AddMeshToRender,
    AddDirectionalLightToRender=AddDirectionalLightToRender,
    AddPointLightToRender=AddPointLightToRender,
};

OnModuleReload :: (id : ModuleID) {
    if id == Module_ID {
        g_context = remap_context();
    }
}

#program_export
ModuleHandshake :: (core : *CoreModule) -> *Module #c_call {
    g_core = core;
    return *g_module;
}

g_context : #Context;

InitializeRenderer :: () {
    g_context = remap_context();
    push_context,defer_pop g_context;
}

ShutdownRenderer :: () {
    push_context,defer_pop g_context;
}

WaitForRenderThread :: () {
    push_context,defer_pop g_context;
}

AddMeshToRender :: (mesh : MeshToRender) {
    push_context,defer_pop g_context;
}

AddDirectionalLightToRender :: (light : DirectionalLightToRender) {
    push_context,defer_pop g_context;
}

AddPointLightToRender :: (light : PointLightToRender) {
    push_context,defer_pop g_context;
}
