#import "Math";

#load "world.jai";
#load "entity.jai";
#load "component.jai";

GameModule :: struct {
    #as using _ : Module;

    world : WorldAPI;
    entity : EntityAPI;
    component : ComponentAPI;
}

#if Module_ID != .Game {

g_game : *GameModule;

}
