package com.litl.turfwar {
    import com.litl.sdk.event.RemoteStatusEvent;
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.richinput.RemoteManager;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.event.NoPlayersEvent;

    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    public class RemoteControlModel extends EventDispatcher {
        private var nextPlayerId:int;

        private var remoteManager:RemoteManager;
        public var remoteIds:Array;
        public var players:Dictionary;

        public function RemoteControlModel(service:LitlService) {
            remoteManager = new RemoteManager(service);
            remoteManager.addEventListener(RemoteStatusEvent.REMOTE_STATUS, handleRemoteStatus);

            remoteIds = new Array();
            players = new Dictionary();

            nextPlayerId = Player.INVALID_PLAYER_ID;
        }

        protected function handleRemoteStatus(e:RemoteStatusEvent):void {
            var remote:IRemoteControl = e.remote;
            if (remote != null && remote.hasAccelerometer) {
                if (e.remoteEnabled) {
                    handleRemoteConnect(remote);
                } else {
                    handleRemoteDisconnect(remote);
                    if (remoteIds.length == 0) {
                        dispatchEvent(new NoPlayersEvent());
                    }
                }
            }
        }

        protected function handleRemoteDisconnect(remote:IRemoteControl):void {
            var remoteId:String = remote.id;
            remoteIds.splice(remoteIds.indexOf(remoteId), 1);

            var player:Player = players[remoteId];
            player.destroy();
        }

        protected function handleRemoteConnect(remote:IRemoteControl):void {
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
