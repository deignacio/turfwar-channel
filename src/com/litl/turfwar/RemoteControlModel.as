package com.litl.turfwar {
    import com.litl.sdk.event.RemoteStatusEvent;
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.richinput.remotehandler.IRemoteHandler;
    import com.litl.sdk.richinput.remotehandler.RemoteHandlerManager;
    import com.litl.sdk.richinput.RemoteManager;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.enum.ArenaSize;
    import com.litl.turfwar.enum.ArenaWrap;
    import com.litl.turfwar.enum.GameSpeed;
    import com.litl.turfwar.event.CrashEvent;
    import com.litl.turfwar.event.NoPlayersEvent;

    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    public class RemoteControlModel extends RemoteHandlerManager {
        public var scores:Array;
        public var arena:ArenaModel;
        private var _speed:GameSpeed;
        private var gameTimer:Timer;
        private var crashing:Boolean;

        public function RemoteControlModel(service:LitlService) {
            super(service, new PlayerFactory());

            gameTimer = new Timer(0, 0);
            speed = GameSpeed.NORMAL;
            gameTimer.addEventListener(TimerEvent.TIMER, handleTick);

            scores = new Array();

            crashing = false;

            arena = new ArenaModel(ArenaSize.MEDIUM, ArenaWrap.WRAP_NO);

            start();
        }

        public function reset():void {
            crashing = false;

            arena.reset();
            forEachPlayer(arena.enterArena);
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

        public function forEachPlayer(func:Function):void {
            var outer:Function = function(handler:IRemoteHandler):void {
                func(handler as Player);
            };
            forEachHandler(outer);
        }

        protected function resumePlayer(player:Player):void {
            player.resume();
        }

        protected function pausePlayer(player:Player):void {
            player.pause();
        }

        override protected function onRemoteStatus(remote:IRemoteControl):void {
            recomputeScores();
        }

        override protected function onRemoteConnected(remote:IRemoteControl, handler:IRemoteHandler):void {
            var player:Player = handler as Player;
            player.addEventListener(CrashEvent.CRASH, onCrash);
            scores.push(player.score);
            arena.enterArena(player);
        }

        override protected function onRemoteDisconnected(remote:IRemoteControl, handler:IRemoteHandler):void {
            var player:Player = handler as Player;
            player.removeEventListener(CrashEvent.CRASH, onCrash);
            scores.splice(scores.indexOf(player.score), 1);
            arena.leaveArena(player);

            if (numConnected == 0) {
                dispatchEvent(new NoPlayersEvent());
            }
        }

        protected function onCrash(e:CrashEvent):void {
            crashing = true;

            var causerId:int = e.causerId;
            var recordCrashCause:Function = function(player:Player):void {
                if (player.id == causerId) {
                    player.recordCrashCause();
                }
            };
            forEachPlayer(recordCrashCause);

            recomputeScores();
            dispatchEvent(e);
        }

        protected function recomputeScores():void {
            scores.sort(PlayerScore.compareFunction);
        }

        protected function handleTick(e:TimerEvent):void {
            if (crashing) {
                return;
            }

            forEachPlayer(processPlayer);

            dispatchEvent(e);
        }

        protected function processPlayer(player:Player):void {
            player.maybeTurn();
            arena.movePlayer(player);
        }
    }
}
