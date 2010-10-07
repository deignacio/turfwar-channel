package com.litl.turfwar {
    import com.litl.sdk.richinput.remotehandler.IRemoteHandler;
    import com.litl.sdk.richinput.remotehandler.IRemoteHandlerFactory;

    public class PlayerFactory implements IRemoteHandlerFactory {
        public static const INVALID_PLAYER_ID:int = 0;
        private var nextPlayerId:int = INVALID_PLAYER_ID;

        public function createHandler():IRemoteHandler {
            return new Player(++nextPlayerId);
        }

        public function get klass():Class {
            return Player;
        }
    }
}
