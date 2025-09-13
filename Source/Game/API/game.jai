#import "Math";

#load "world.jai";
#load "entity.jai";

GameModule :: struct {
    #as base : Module;

    world : WorldAPI;
    entity : EntityAPI;
}

#if Module_ID != .Game {

#insert -> string {
    dummy : *GameModule;
    return "using,except(base) g_game : *GameModule;";
}

}
