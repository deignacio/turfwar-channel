package com.litl {
    import com.litl.sdk.message.InitializeMessage;
    import com.litl.sdk.message.UserInputMessage;
    import com.litl.sdk.message.ViewChangeMessage;
    import com.litl.sdk.service.LitlService;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.utils.Dictionary;
    import com.litl.view.ViewBase;

    [SWF(backgroundColor="0xffffff", width="1280", height="800", frameRate="21")]
    public class BaseChannel extends Sprite {
        protected var service:LitlService;
        protected var views:Dictionary;
        protected var currentView:ViewBase;

        public function BaseChannel() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            setupService();
            setupViews();
            connectToService();
        }

        private function setupService():void {
            service = new LitlService(this);
            service.addEventListener(InitializeMessage.INITIALIZE, handleInitialize);
            service.addEventListener(UserInputMessage.GO_BUTTON_PRESSED, handleGoPressed);
            service.addEventListener(UserInputMessage.GO_BUTTON_HELD, handleGoHeld);
            service.addEventListener(UserInputMessage.GO_BUTTON_RELEASED, handleGoReleased);
            setup();
        }

        /**
         * the customary location to add any more event listeners
         * to the litl service, or setup any data models or graphics
         *
         * @see com.litl.sdk.service.ILitlService
         */
        protected function setup():void {
        }

        /**
         * this is called once the channel is finished initializing and can
         * begin running.
         *
         * good things to set here are:
         * service.channelTitle
         * service.channelItemCount
         *
         * possibly start any timers or display a login screen
         */
        protected function handleInitialize(e:InitializeMessage):void {
        }

        private function setupViews():void {
            service.addEventListener(ViewChangeMessage.VIEW_CHANGE, handleViewChange);
            views = new Dictionary();
            registerViews();
        }

        /**
         * registers the appropriate view objects for handling by the
         * channel.  you must include one view for each of the View
         * constants.
         *
         * @see com.litl.sdk.enum.View
         */
        protected function registerViews():void {
        }

        private function handleViewChange(e:ViewChangeMessage):void {
            var newView:String = e.view;
            var newDetails:String = e.details;
            var viewWidth:Number = e.width;
            var viewHeight:Number = e.height;

            // Remove the current view from the display list.
            if (currentView && contains(currentView)) {
                removeChild(currentView);
            }

            currentView = ensureView(newView);
            currentView.setSize(viewWidth, viewHeight);

            if (!contains(currentView))
                addChild(currentView);

            onViewChanged(newView, newDetails, viewWidth, viewHeight);
        }

        /**
         * if you do not want to create all of your views at channel
         * start, or if you might have to remove views during runtime
         * due to resource constraints, override this method to
         * lazy-load any views that you want
         */
        protected function ensureView(newView:String):ViewBase {
            return views[newView] as ViewBase;
        }

        /**
         * place any channel logic that is based upon the view here.
         *
         * good examples are:
         * pausing any timers while OFFSCREEN, or not playing audio
         * while in CARD view, possibly changing the channel title
         * based on the view
         *
         * @see com.litl.sdk.enum.View
         * @see com.litl.sdk.enum.ViewDetails
         */
        protected function onViewChanged(newView:String, newDetails:String, viewWidth:Number = 0, viewHeight:Number = 0):void {
        }

        /**
         * Connect to the litl service here.  All other setup or registration is done.
         * The channel can run now.
         *
         * This should contain a service.connect(); invocation
         */
        protected function connectToService():void {
        }

        /**
         * Called when the go button is pressed.
         *
         * NOTE:  Only dispatched when the channel is in CHANNEL view.
         */
        protected function handleGoPressed(e:UserInputMessage):void {
        }

        /**
         * Called when the go button is held for one second.
         *
         * NOTE:  Only dispatched when the channel is in CHANNEL view.
         */
        protected function handleGoHeld(e:UserInputMessage):void {
        }

        /**
         * Called when the go button is released.
         *
         * NOTE:  Only dispatched when the channel is in CHANNEL view.
         */
        protected function handleGoReleased(e:UserInputMessage):void {
        }
    }
}
