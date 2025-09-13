#load "Build/assets.jai";

HandleCompilerMessageForCore :: (msg : *Message) {
    if msg.kind == {
    case .TYPECHECKED;
        typechecked := cast(*Message_Typechecked, msg);
        for typechecked.declarations {
            decl := it.expression;
            if !decl {
                continue;
            }

            HandleDeclarationForAsset(msg.workspace, decl);
        }

    case .PHASE;
        phase := cast(*Message_Phase, msg);
        if phase.phase == .TYPECHECKED_ALL_WE_CAN {
            GenerateAssetCode(msg.workspace);
        }
    }
}
