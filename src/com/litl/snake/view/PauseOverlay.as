package com.litl.snake.view
{
    import com.litl.control.Label;
    import com.litl.helpers.view.ViewBase;

    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    import flash.utils.Timer;

    import printf;

    /**
     * Meant to be a common place for messages that need to be
     * conveyed to the user should be displayed.
     *
     */
    public class PauseOverlay extends ViewBase {
        public static const DIMMED_BACKGROUND_ALPHA:Number = 0.25;
        public static const DEFAULT_UNPAUSE_DELAY_SECONDS:Number = 3;
        public static const DEFAULT_PAUSED_MESSAGE:String = "game paused";
        public static const DEFAULT_UNPAUSING_MESSAGE:String = "unpausing in %(remaining)d...";

        private var _dimBackground:Sprite;
        private var _messageLabel:Label;
        private var _view:ViewBase;
        private var _unpauseTimer:Timer;

        private var _delay:Number;
        private var _pausedMessage:String;
        private var _unpausingMessage:String;

        private var _childViews:Dictionary;
        private var _disabledDimViews:Array;

        public function PauseOverlay(delay:Number = DEFAULT_UNPAUSE_DELAY_SECONDS,
                                    pausedMessage:String = DEFAULT_PAUSED_MESSAGE,
                                    unpausingMessage:String = DEFAULT_UNPAUSING_MESSAGE) {
            super();

            _delay = delay;
            _pausedMessage = pausedMessage;
            _unpausingMessage = unpausingMessage;

            _unpauseTimer = new Timer(1000, _delay);
            _unpauseTimer.addEventListener(TimerEvent.TIMER, onUnpauseTimer);
            _unpauseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onUnpauseTimerComplete);

            _dimBackground = new Sprite();
            _childViews = new Dictionary();
            _disabledDimViews = new Array(4);

            _messageLabel = new Label();
            _messageLabel.move(25, 50);
            _messageLabel.useFTE = true;
            _messageLabel.autoSize = TextFieldAutoSize.LEFT;
            _dimBackground.addChild(_messageLabel);
        }

        public function set view(value:ViewBase):void {
            if (_view != value) {
                hideView();
                _view = value;
            }
        }

        override public function setSize(w:Number, h:Number):void {
            super.setSize(w, h);

            _dimBackground.graphics.clear();
            _dimBackground.graphics.beginFill(0xffffff, DIMMED_BACKGROUND_ALPHA);
            _dimBackground.graphics.drawRect(0, 0, width, height);
            _dimBackground.graphics.endFill();
        }

        public function set message(value:String):void {
            _messageLabel.text = value;
        }

        public function disableDimForViews(views:Array):void {
            for (var i:int = 0; i < views.length; i++) {
                if (_disabledDimViews.indexOf(views[i]) == -1) {
                    _disabledDimViews.push(views[i]);
                }
            }
        }

        public function enableDimForViews(views:Array):void {
            var j:int;
            for (var i:int = 0; i < views.length; i++) {
                j = _disabledDimViews.indexOf(views[i]);
                if (j != -1) {
                    _disabledDimViews.splice(j, 1);
                }
            }
        }

        private function maybeDimView():void {
            if (_disabledDimViews.indexOf(_view) == -1) {
                addChild(_dimBackground);
            } else if (contains(_dimBackground)) {
                removeChild(_dimBackground);
            }
        }

        public function addChildForViews(child:PausedViewBase, views:Array):void {
            var children:Array;
            for (var i:int = 0; i < views.length; i++) {
                children = _childViews[views[i]];
                if (children == null) {
                    _childViews[views[i]] = new Array();
                    children = _childViews[views[i]];
                }

                if (children.indexOf(child) == -1) {
                    children.push(child);
                }
            }
        }

        public function removeChildForViews(child:PausedViewBase, views:Array):void {
            var children:Array;
            var j:int;
            for (var i:int = 0; i < views.length; i++) {
                children = _childViews[views[i]];
                if (children != null) {
                    j = children.indexOf(child);
                    if (j != -1) {
                        children.splice(j, 1);
                    }
                }
            }
        }

        private function addChildren():void {
            var children:Array = _childViews[_view] as Array;
            if (children != null) {
                for (var i:int = 0; i < children.length; i++) {
                    children[i].refresh();
                    addChild(children[i]);
                }
            }
        }

        private function removeChildren():void {
            var children:Array = _childViews[_view];
            if (children != null) {
                for (var i:int = 0; i < children.length; i++) {
                    removeChild(children[i]);
                }
            }
        }

        public function pause():void {
            _unpauseTimer.stop();
            _unpauseTimer.reset();

            var pauseInfo:Object = {
                'delay': _delay,
                'remaining': _delay - _unpauseTimer.currentCount
            };
            message = printf(_pausedMessage, pauseInfo);
            showView();
        }

        public function unpause():void {
            if (!_unpauseTimer.running) {
                onUnpauseTimer(null);
                _unpauseTimer.start();
            }

            showView();
        }

        protected function onUnpauseTimer(e:TimerEvent):void {
            if (_unpauseTimer.currentCount != _delay) {
                var unpauseInfo:Object = {
                    'delay': _delay,
                    'remaining': _delay - _unpauseTimer.currentCount
                };
                message = printf(_unpausingMessage, unpauseInfo);
            }
        }

        protected function onUnpauseTimerComplete(e:TimerEvent):void {
            hideView();
            dispatchEvent(e);
        }

        private function hideView():void {
            if (_view != null && _view.contains(this)) {
                removeChildren();
                _view.removeChild(this);
            }
        }

        private function showView():void {
            if (_view != null) {
                setSize(_view.width, _view.height);
                maybeDimView();
                addChildren();
                _view.addChild(this);
            }
        }
    }
}
