package {
    import com.litl.BaseChannel;
    import com.litl.sdk.enum.View;
    import com.litl.sdk.message.*;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.RemoteControlVisualiser;
    import com.litl.turfwar.event.NoPlayersEvent;
    import com.litl.turfwar.view.CardView;
    import com.litl.turfwar.view.OptionsView;
    import com.litl.turfwar.view.PauseOverlay;
    import com.litl.turfwar.view.Scoreboard;
    import com.litl.view.ViewBase;

    import flash.events.TimerEvent;

    public class TurfWarChannel extends BaseChannel {
        public static const CHANNEL_ENGINE_GUID:String = "turfwar-channel";
        public static const CHANNEL_TITLE:String = "Turf Wars Channel";
        public static const CHANNEL_VERSION:String = "1.0";
        public static const CHANNEL_HAS_OPTIONS:Boolean = false;

        protected var dataModel:RemoteControlModel;
        protected var dataVisualiser:RemoteControlVisualiser;

        protected var pauseOverlay:PauseOverlay;

        public function TurfWarChannel() {
            super();
        }

        override protected function setup():void {
            dataModel = new RemoteControlModel(service);
            dataModel.addEventListener(NoPlayersEvent.NO_PLAYERS, onNoPlayers);
            dataVisualiser = new RemoteControlVisualiser(dataModel);
        }

        override protected function registerViews():void {
            var cardView:ViewBase = new CardView();
            views[View.CARD] = cardView;

            var focusView:ViewBase = new ViewBase();
            views[View.FOCUS] = focusView;

            var channelView:ViewBase = new ViewBase();
            views[View.CHANNEL] = channelView;

            pauseOverlay = new PauseOverlay();
            pauseOverlay.addEventListener(TimerEvent.TIMER_COMPLETE, onUnpause);
            pauseOverlay.pause(this);

            pauseOverlay.disableDimForViews([cardView]);

            var optionsView:OptionsView = new OptionsView(dataModel, service);
            pauseOverlay.addChildForViews(optionsView, [focusView]);

            var scoreboard:Scoreboard = new Scoreboard(dataModel);
            pauseOverlay.addChildForViews(scoreboard, [focusView, channelView]);
        }

        override protected function connectToService():void {
            service.connect(CHANNEL_ENGINE_GUID, CHANNEL_TITLE, CHANNEL_VERSION, CHANNEL_HAS_OPTIONS);
        }

        /** if there are no more players, pause the game */
        protected function onNoPlayers(e:NoPlayersEvent):void {
            pauseGame();
        }

        protected function unpauseGame():void {
            if (!dataModel.running) {
                if (dataModel.remoteIds.length > 0) {
                    pauseOverlay.unpause(currentView);
                } else {
                    pauseOverlay.pause(currentView);
                    pauseOverlay.setMessage("game paused\nno players!");
                }
            }
        }

        protected function onUnpause(e:TimerEvent):void {
            trace("unpause complete!");
            dataVisualiser.drawEverything();
            dataModel.unpause();
        }

        protected function pauseGame():void {
            pauseOverlay.pause(currentView);
            if (dataModel.remoteIds.length == 0) {
                pauseOverlay.setMessage("game paused\nno players!");
            }
            dataModel.pause();
        }

        override protected function handleInitialize(e:InitializeMessage):void {
            service.channelTitle = CHANNEL_TITLE;
            service.channelItemCount = 1;
        }

        override protected function onViewChanged(newView:String, newDetails:String, viewWidth:Number = 0, viewHeight:Number = 0):void {
            dataVisualiser.view = currentView;
            if (newView != View.CARD) {
                dataVisualiser.drawEverything();
            }

            pauseGame();
        }

        override protected function handleGoReleased(e:UserInputMessage):void {
            if (dataModel.running) {
                pauseGame();
            } else {
                unpauseGame();
            }
        }
    }
}
