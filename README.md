# Jai Hot-Reloading Experiment
This is a simple proof of concept code hot reloading in Jai.

Inspired by https://allyourfaultforever.com/posts/jai-hot-reload/

The main program is very minimal, and does not even create the window. It merely loads the library, calls a few callbacks and watch for file changes.

I have also added a game state size global that gets compared with the current state size when doing the handshake to detect memory layout changes.

Finally there is the @GlobalPersistent note that allows you to declare global state that will be persistent between module reloads.
