package
{
    import com.litl.turfwar.view.ViewBase;
    import com.litl.sdk.enum.View;
    import com.litl.sdk.enum.ViewDetails;
    import com.litl.sdk.event.*;
    import com.litl.sdk.message.*;
    import com.litl.sdk.richinput.*;
    import com.litl.sdk.service.LitlService;

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    [SWF(backgroundColor="0xffffff", width="1280", height="800", frameRate="21")]
    public class TurfWarChannel extends Sprite
    {
        protected var service:LitlService;
        protected var currentView:ViewBase;
        protected var views:Dictionary;

        public function TurfWarChannel() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            initialize();
        }

        protected function initialize():void {
            service = new LitlService(this);

            service.addEventListener(InitializeMessage.INITIALIZE, handleInitialize);
            service.addEventListener(ViewChangeMessage.VIEW_CHANGE, handleViewChange);

            service.connect("turfwar-channel", "Turf Wars", "1.0", false);
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

            if (currentView == null)
                currentView = new ViewBase();

            views[newView] = currentView;

            currentView.setSize(viewWidth, viewHeight);

            if (!contains(currentView))
                addChild(currentView);
        }
    }
}
