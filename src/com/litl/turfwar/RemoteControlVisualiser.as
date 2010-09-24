package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.util.Tween;
    import com.litl.turfwar.event.CrashEvent;
    import com.litl.turfwar.view.HeadsUpGameView;
    import com.litl.turfwar.view.IGameView;
    import com.litl.turfwar.view.PlayerShape;
    import com.litl.view.ViewBase;

    import flash.display.Shape;
    import flash.events.Event;
    import flash.events.TimerEvent;

    public class RemoteControlVisualiser {
        protected var dataModel:RemoteControlModel;
        public var view:ViewBase;

        private var gameViews:Array;

        private var crashedId:int;
        private var stillCrashing:Array;

        private static const COLORS:Array = [ 0x000000, 0xff0000, 0x0000ff, 0x00ff00,
            0xffffff, 0x9AD7DB, 0x76d5db, 0x56d3db,
            0x2cd0db, 0x00cedb, 0x00cedb ];

        public static function getColor(playerId:int):uint {
            return COLORS[playerId % COLORS.length];
        }

        public function RemoteControlVisualiser(dataModel:RemoteControlModel) {
            this.dataModel = dataModel;
            dataModel.addEventListener(CrashEvent.CRASH, onCrash);
            dataModel.addEventListener(TimerEvent.TIMER, handleTimerTick);

            stillCrashing = new Array();
            gameViews = new Array();

            gameViews.push(new HeadsUpGameView(dataModel, this, 1, 1, 0.0, 0));
        }

        protected function handleTimerTick(e:TimerEvent):void {
            forEachGameView(drawView);

            e.stopPropagation();
        }

        protected function forEachGameView(func:Function):void {
            var gameView:IGameView;
            for (var i:int = 0; i < gameViews.length; i++) {
                gameView = gameViews[i] as IGameView;
                if (gameView != null) {
                    func(gameView);
                }
            }
        }

        protected function onCrash(e:CrashEvent):void {
            crashedId = e.player.id;
            forEachGameView(crashView);
        }

        protected function crashView(gameView:IGameView):void {
            stillCrashing.push(gameView);
            gameView.crash(crashedId);
        }

        public function doneCrashing(gameView:IGameView):void {
            stillCrashing.splice(stillCrashing.indexOf(gameView), 1);
            if (stillCrashing.length == 0) {
                forEachGameView(clearView);
                dataModel.reset();
            }
        }

        protected function clearView(gameView:IGameView):void {
            gameView.clear();
        }

        protected function drawView(gameView:IGameView):void {
            gameView.draw(view);
        }

        public function drawEverything():void {
            forEachGameView(drawEverythingView);
        }

        protected function drawEverythingView(gameView:IGameView):void {
            gameView.drawEverything(view);
        }
    }
}
