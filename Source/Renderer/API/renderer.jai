#import "Math";

RendererModule :: struct {
    #as base : Module;

    WaitForRenderThread : ();
    AddMeshToRender : (mesh : MeshToRender);
    AddDirectionalLightToRender : (light : DirectionalLightToRender);
    AddPointLightToRender : (light : PointLightToRender);
}

#if Module_ID != .Renderer {

using,except(base) g_renderer : *RendererModule;

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
