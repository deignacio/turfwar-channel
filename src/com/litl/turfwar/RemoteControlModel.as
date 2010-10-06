package com.litl.turfwar {
    import com.litl.sdk.event.RemoteStatusEvent;
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.richinput.RemoteManager;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.enum.ArenaSize;
    import com.litl.turfwar.enum.ArenaWrap;
    import com.litl.turfwar.enum.GameSpeed;
    import com.litl.turfwar.event.NoPlayersEvent;
    import com.litl.turfwar.event.CrashEvent;

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    public class RemoteControlModel extends EventDispatcher {
        private var nextPlayerId:int;

        private var remoteManager:RemoteManager;
        public var remoteIds:Array;
        public var scores:Array;
        public var players:Dictionary;
        public var arena:ArenaModel;
        private var _speed:GameSpeed;
        private var gameTimer:Timer;

        public function RemoteControlModel(service:LitlService) {
            remoteManager = new RemoteManager(service);
            remoteManager.addEventListener(RemoteStatusEvent.REMOTE_STATUS, handleRemoteStatus);

            gameTimer = new Timer(0, 0);
            speed = GameSpeed.NORMAL;
            gameTimer.addEventListener(TimerEvent.TIMER, handleTick);

            remoteIds = new Array();
            players = new Dictionary();
            scores = new Array();

            nextPlayerId = Player.INVALID_PLAYER_ID;

            arena = new ArenaModel(ArenaSize.MEDIUM, ArenaWrap.WRAP_NO);
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
                func(player);
            }
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
            player.removeEventListener(CrashEvent.CRASH, onCrash);
            scores.splice(scores.indexOf(player.score), 1);
            arena.leaveArena(player);
            player.destroy();
            recomputeScores();
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
                player.addEventListener(CrashEvent.CRASH, onCrash);
                scores.push(player.score);
                arena.enterArena(player);
            }
            recomputeScores();
        }

        protected function onCrash(e:CrashEvent):void {
            var causerId:int = e.causerId;
            var recordCrashCause:Function = function(player:Player):void {
                if (player.id == causerId) {
                    player.recordCrashCause();
                }
            };
            forEachPlayer(recordCrashCause);

            recomputeScores();
            pause();
            dispatchEvent(e);
        }

        protected function recomputeScores():void {
            scores.sort(PlayerScore.compareFunction);
        }

        protected function handleTick(e:TimerEvent):void {
            // TODO: implement this
        }
    }
}
