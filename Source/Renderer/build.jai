Renderer_Module_Dependencies :: string.[
    "Source/Core/API",
];

HandleCompilerMessageForRenderer :: (msg : *Message) {
    HandleCompilerMessageForCore(msg);
}
