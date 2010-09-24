package
{
    import com.litl.sdk.enum.View;
    import com.litl.sdk.enum.ViewDetails;
    import com.litl.sdk.event.*;
    import com.litl.sdk.message.*;
    import com.litl.sdk.richinput.*;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.RemoteControlVisualiser;
    import com.litl.turfwar.enum.GameSpeed;
    import com.litl.turfwar.view.CardView;
    import com.litl.turfwar.view.OptionsView;
    import com.litl.turfwar.view.PauseOverlay;
    import com.litl.turfwar.view.ViewBase;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;

    [SWF(backgroundColor="0xffffff", width="1280", height="800", frameRate="21")]
    public class TurfWarChannel extends Sprite
    {
        protected var service:LitlService;
        protected var currentView:ViewBase;
        protected var views:Dictionary;

        protected var remoteManager:RemoteManager;
        protected var dataModel:RemoteControlModel;
        protected var dataVisualiser:RemoteControlVisualiser;

        protected var pauseOverlay:PauseOverlay;
        protected var optionsView:OptionsView;

        public function TurfWarChannel() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            initialize();
        }

        protected function initialize():void {
            service = new LitlService(this);

            remoteManager = new RemoteManager(service);
            dataModel = new RemoteControlModel();
            dataVisualiser = new RemoteControlVisualiser(dataModel);
            dataModel.addEventListener(TimerEvent.TIMER, handleTimerTick);
            remoteManager.addEventListener(RemoteStatusEvent.REMOTE_STATUS, handleRemoteStatus);

            service.addEventListener(InitializeMessage.INITIALIZE, handleInitialize);
            service.addEventListener(ViewChangeMessage.VIEW_CHANGE, handleViewChange);
            service.addEventListener(OptionsStatusMessage.OPTIONS_STATUS, handleOptionsStatus);

            pauseOverlay = new PauseOverlay();
            pauseOverlay.addEventListener(TimerEvent.TIMER_COMPLETE, onUnpause);
            pauseOverlay.pause(this);

            service.connect("turfwar-channel", "Turf Wars", "1.0", true);
        }

        protected function unpauseGame():void {
            var view:Sprite = (currentView == null) ? this : currentView;
            if (!dataModel.running) {
                if (dataModel.remoteIds.length > 0) {
                    pauseOverlay.unpause(view);
                } else {
                    pauseOverlay.pause(view);
                    pauseOverlay.setMessage("game paused\nno players!");
                }
            } else {
                dataVisualiser.drawWholeGame(view);
            }
        }

        protected function onUnpause(e:TimerEvent):void {
            trace("unpause complete!");
            var view:Sprite = (currentView == null) ? this : currentView;
            dataVisualiser.drawWholeGame(view);
            dataModel.unpause();
        }

        protected function pauseGame():void {
            var view:Sprite = (currentView == null) ? this : currentView;
            pauseOverlay.pause(view);
            if (dataModel.remoteIds.length == 0) {
                pauseOverlay.setMessage("game paused\nno players!");
            }
            dataModel.pause();
        }

        /**
         * Called when the device has sent all our saved properties, and is ready for us to begin.
         * @param e    The InitializeMessage instance.
         *
         */
        private function handleInitialize(e:InitializeMessage):void {
            service.channelTitle = "Turf Wars Channel";
            service.channelItemCount = 1;
        }

        /**
         * Called when the device has changed views. From focus to card view, for instance.
         * @param e    The ViewChangeMessage instance.
         *
         */
        private function handleViewChange(e:ViewChangeMessage):void {
            // When the device sends us a ViewChangeMessage, we should change our content
            // to match the new view.
            var newView:String = e.view;
            var newDetails:String = e.details;
            var viewWidth:Number = e.width;
            var viewHeight:Number = e.height;
            setView(newView, newDetails, viewWidth, viewHeight);
        }

        private function handleTimerTick(event:TimerEvent):void {
            if (currentView != null) {
                dataVisualiser.drawGame(currentView);
            }
            event.stopPropagation();
        }

        private function handleRemoteStatus(e:RemoteStatusEvent):void {
            var remote:IRemoteControl = e.remote;
            if (remote != null && remote.hasAccelerometer) {
                if (e.remoteEnabled) {
                    dataModel.handleRemoteConnect(remote);
                    unpauseGame();
                } else {
                    dataModel.handleRemoteDisconnect(remote);
                    if (dataModel.remoteIds.length == 0) {
                        pauseGame();
                    }
                }
            }
        }

        private function handleOptionsStatus(e:OptionsStatusMessage):void {
            if (e.optionsOpen) {
                showOptions();
            } else {
                hideOptions();
            }
        }

        private function showOptions():void {
            if (optionsView == null) {
                optionsView = new OptionsView(dataModel, service);
            }
            if (!contains(optionsView)) {
                pauseGame();
                addChild(optionsView);
            }
        }

        private function hideOptions():void {
            if (optionsView != null && contains(optionsView)) {
                removeChild(optionsView);
                optionsView = null;
                unpauseGame();
            }
        }

        /**
         * Set the current view. Create the view if it doesn't exist, and switch to it.
         * @param newView        The view constant.
         * @param newDetails    The view details.
         * @see com.litl.sdk.enum.View
         */
        public function setView(newView:String, newDetails:String, viewWidth:Number = 0, viewHeight:Number = 0):void {
            trace("Setting view: " + newView + " " + newDetails + " (" + viewWidth + ", " + viewHeight + ")");

            // Remove the current view from the display list.
            if (currentView && contains(currentView)) {
                removeChild(currentView);
            }

            if (views == null)
                views = new Dictionary(false);

            currentView = views[newView] as ViewBase;

            if (currentView == null) {
                if (newView == View.CARD) {
                    currentView = new CardView();
                } else {
                    currentView = new ViewBase();
                }
            }

            views[newView] = currentView;

            currentView.setSize(viewWidth, viewHeight);

            if (!contains(currentView))
                addChild(currentView);

            if (newDetails != ViewDetails.NORMAL || newView == View.CARD) {
                pauseGame();
            } else {
                unpauseGame();
            }
        }
    }
}
