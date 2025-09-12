#load "Build/entity.jai";

HandleCompilerMessageForGame :: (msg : *Message) {
    HandleCompilerMessageForCore(msg);

    if msg.kind == {
    case .TYPECHECKED;
        typechecked := cast(*Message_Typechecked, msg);
        for typechecked.declarations {
            decl := it.expression;
            if !decl {
                continue;
            }

            HandleDeclarationForEntity(msg.workspace, decl);
        }

    case .PHASE;
        phase := cast(*Message_Phase, msg);
        if phase.phase == .TYPECHECKED_ALL_WE_CAN {
            GenerateEntityCode(msg.workspace);
        }
    }
}
