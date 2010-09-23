package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;

    import flash.utils.Dictionary;

    public class RemoteControlModel {
        private var nextPlayerId:int;

        public var remoteIds:Array;
        public var players:Dictionary;

        public function RemoteControlModel() {
            remoteIds = new Array();
            players = new Dictionary();

            nextPlayerId = Player.INVALID_PLAYER_ID;
        }

        public function handleRemoteDisconnect(remote:IRemoteControl):void {
            var remoteId:String = remote.id;
            remoteIds.splice(remoteIds.indexOf(remoteId), 1);

            var player:Player = players[remoteId];
            player.destroy();
        }

        public function handleRemoteConnect(remote:IRemoteControl):void {
            var remoteId:String = remote.id;
            if (remoteIds.indexOf(remoteId) == -1) {
                remoteIds.push(remoteId);

                if (!players.hasOwnProperty(remoteId)) {
                    players[remoteId] = new Player(++nextPlayerId);
                }

                var player:Player = players[remoteId];
                player.associateRemote(remote);
            }
        }
    }
}
