#import "Math";

RendererModule :: struct {
    #as using _ : Module;

    WaitForRenderThread : ();
    AddMeshToRender : (mesh : MeshToRender);
    AddDirectionalLightToRender : (light : DirectionalLightToRender);
    AddPointLightToRender : (light : PointLightToRender);
}

#if Module_ID != .Renderer {

g_renderer : *RendererModule;

WaitForRenderThread :: inline () {
    assert(g_renderer != null, "Renderer module is null");

    g_renderer.WaitForRenderThread();
}

AddMeshToRender :: inline (mesh : MeshToRender) {
    assert(g_renderer != null, "Renderer module is null");

    g_renderer.AddMeshToRender(mesh);
}

AddDirectionalLightToRender :: inline (light : DirectionalLightToRender) {
    assert(g_renderer != null, "Renderer module is null");

    g_renderer.AddDirectionalLightToRender(light);
}

AddPointLightToRender :: inline (light : PointLightToRender) {
    assert(g_renderer != null, "Renderer module is null");

    g_renderer.AddPointLightToRender(light);
}

}

MeshToRender :: struct {
    entity_guid : [2]u64;
    transform : Matrix4;
    normal_transform : Matrix3;
    vertex_buffer : *GfxBuffer;
    index_buffer : *GfxBuffer;
    vertex_count : u32;
    index_count : u32;
    is_skinned : bool;
    skinnined_matrices : []Matrix4;
}

DirectionalLightToRender :: struct {
    direction : Vector3;
    color : Vector3;
    intensity : float;
}

PointLightToRender :: struct {
    position : Vector3;
    color : Vector3;
    intensity : float;
}
