package
{
    import com.litl.sdk.enum.View;
    import com.litl.sdk.enum.ViewDetails;
    import com.litl.sdk.event.*;
    import com.litl.sdk.message.*;
    import com.litl.sdk.richinput.*;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.event.NoPlayersEvent;
    import com.litl.turfwar.view.CardView;
    import com.litl.view.ViewBase;

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
        public static const CHANNEL_ENGINE_GUID:String = "turfwar-channel";
        public static const CHANNEL_TITLE:String = "Turf Wars Channel";
        public static const CHANNEL_VERSION:String = "1.0";
        public static const CHANNEL_HAS_OPTIONS:Boolean = false;

        protected var service:LitlService;
        protected var currentView:ViewBase;
        protected var views:Dictionary;

        protected var dataModel:RemoteControlModel;

        public function TurfWarChannel() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            initialize();
        }

        protected function initialize():void {
            service = new LitlService(this);

            dataModel = new RemoteControlModel(service);
            dataModel.addEventListener(NoPlayersEvent.NO_PLAYERS, onNoPlayers);

            service.addEventListener(InitializeMessage.INITIALIZE, handleInitialize);
            service.addEventListener(ViewChangeMessage.VIEW_CHANGE, handleViewChange);

            service.connect(CHANNEL_ENGINE_GUID, CHANNEL_TITLE, CHANNEL_VERSION, CHANNEL_HAS_OPTIONS);
        }

        /** if there are no more players, pause the game */
        protected function onNoPlayers(e:NoPlayersEvent):void {
            pauseGame();
        }

        /**
         * Called when the device has sent all our saved properties, and is ready for us to begin.
         *
         */
        private function handleInitialize(e:InitializeMessage):void {
            service.channelTitle = CHANNEL_TITLE;
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
        }
    }
}
