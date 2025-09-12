# Jai Hot-Reloadable Module Experiment
This is an example program that demonstrates how to do hot reloading in Jai, as well as implements a hot reloadable module system in Jai.

## Hot reloading
Usually when people write about hot reloading, they only explore the easy part, that is the hot reloading itself.
For hot reloading to be useful you need to separate the different systems of your engine into modules, because hot reloading is useful when initialization time starts to be more than a few hundred milliseconds, which happens when you load many assets and create many graphics shaders and pipelines (so you could separate the assets, renderer and game code).
If your initialization time is really fast, it is sufficient to save your state, close the program, launch the program and restore the state, and all code can live monolithically in the executable.

This means the hard part is actually how you make these modules communicate with each other, as well as how you decide to make the state of your modules persistent.

## The modules

## Making global state persistent
To keep the state persistent, I have decided to go down the serialization route, there are multiple reasons for it:
1- I would like to make the development experience in the engine very good, and for that I believe we need to allow users to create new entities and change their layout in Jai without having to close and reopen the editor, waiting for all assets and shaders to load, and graphics pipelines to be created
2- We already have the ability to serialize/deserialize entities in a robust way so I believe we are halfway there, although we probably don't want to use that system for the rest of the state, because it requires versioning the fields we want to serialize which is a pain (maybe not so much)
3- Not all state in a module needs to be saved, a lot of state can simply be rebuilt very fast (and is already rebuilt upon initialization, so you already have to code for it). This is nice because it means we only have to care about serializing some state when we realize it is important for developer experience, and we do not have to try and build a solution that will try to save all of the state
4- In fact, I believe apart from the state of the world for which we already have a serialization system, we only need to serialize the state of the editor (and probably not all the state, i'm sure it's fine if we don't retain what text input was selected).

## Problems
* Type infos being duplicated and different between modules for the same type. This means you can't really compare type infos against each other unless you're sure they're from the same module
