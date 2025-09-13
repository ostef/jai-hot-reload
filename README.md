# Jai Hot-Reloading Experiment
This is an experiment with implementing a code hot reloading in Jai.

I go further as I try to implement an actual module system addressing most of the intricacies of such a system in Jai, instead of just the reloading part.

## Modules
A module is a struct containing runtime assigned function pointers. When we load a module library, we find the ModuleHandshake procedure and call it. This procedure takes as parameter a pointer to CoreModule and returns a pointer to the Module, filled with the appropriate callback functions. The module itself can expose its API by including function pointers inside the module struct. For example:
```jai
Module :: struct {
    Initialize : ();
    Shutdown : ();
    MainLoop : ();
    OnEvent : (event : SDL_Event);
    SaveState : () -> []u8;
    LoadState : (state : []u8);

    OnModuleUnload : (id : ModuleID);
    OnModuleLoad : (id : ModuleID);
}

RendererModule :: struct {
    #as base : Module;

    WaitForRenderThread : ();
    AddMeshToRender : (mesh : MeshToRender);
    AddDirectionalLightToRender : (light : DirectionalLightToRender);
    AddPointLightToRender : (light : PointLightToRender);
}
```

A module is comprised of two to three parts.

The first part, which is contained by convention in the API subdirectory of the module, contains code that is shared between modules and is loaded by other modules to access the module's API.

The second part is the module implementation, which is contained at the root of the module directory. The implementation contains the ModuleHandshake procedure which fills the Module structure and returns it upon loading. Of course it also contains the actual implementation of the module.

Finally, the module can contain a build.jai file and various build related code inside the Build subdirectory. These files are to be loaded inside the root build.jai file.

## The Core module
The Core module is a module that lives in the executable, and cannot be reloaded. It provides code to retrieve the API for a specific module by its ModuleID as well as manage the lifetime of the whole program and other various things:
```jai
CoreModule :: struct {
    #as base : Module;

    Quit : ();
    GetModule : (id : ModuleID) -> *Module;
    GetWindow : () -> *SDL_Window;
    using gfx : GfxAPI;
    using assets : AssetsAPI;
}
```

## Saving and restoring the module state
To save and restore a module's state when it is reloaded, the module needs to implement the `SaveState` and `LoadState` procedures. It is up to the module itself to handle how it saves and restores the state, but to me the most robust way is to serialize and deserialize it, because if done right it can allow changing the memory layout of structs used by the module. We don't provide a serialization system here, because that is quite a complex component and is out of the scope of this experiment.

## Building the program
The build.jai file takes options that tells it what to build. We can decide to build specific modules using `-core`, `-renderer`, `-game` and `-all` options, but we can decide to let the build system detect what to build using the `-auto` option. This option works by comparing the file times of the resulting library or executable of the module with its source files and dependencies (see the various build.jai files).
