package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.turfwar.enum.GameSpeed;

    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    public class RemoteControlModel {
        private var nextPlayerId:int;

        public var remoteIds:Array;
        public var players:Dictionary;
        private var _speed:GameSpeed;
        private var gameTimer:Timer;

        public function RemoteControlModel() {
            gameTimer = new Timer(0, 0);
            speed = GameSpeed.NORMAL;
            gameTimer.addEventListener(TimerEvent.TIMER, handleTick);

            remoteIds = new Array();
            players = new Dictionary();

            nextPlayerId = Player.INVALID_PLAYER_ID;
        }

        public function get speed():GameSpeed {
            return _speed;
        }

        public function set speed(value:GameSpeed):void {
            if (_speed != value) {
                _speed = value;
                gameTimer.delay = _speed.speed;
            }
        }

        public function get running():Boolean {
            return gameTimer.running;
        }

        public function pause():void {
            forEachPlayer(pausePlayer);

            if (gameTimer.running) {
                gameTimer.stop();
            }
        }

        public function unpause():void {
            if (!gameTimer.running) {
                gameTimer.start();
            }

            forEachPlayer(resumePlayer);
        }

        protected function resumePlayer(player:Player):void {
            player.resume();
        }

        protected function pausePlayer(player:Player):void {
            player.pause();
        }

        public function forEachPlayer(func:Function):void {
            for (var i:int = 0; i < remoteIds.length; i++) {
                var remoteId:String = remoteIds[i];
                var player:Player = players[remoteId];
                player.resume();
            }
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

        public function handleTick(e:TimerEvent):void {
            // TODO: implement this
        }
    }
}
