package com.litl.turfwar.view
{
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
    public class PauseOverlay extends Sprite {
        public static const DIMMED_BACKGROUND_ALPHA:Number = 0.75;
        public static const DEFAULT_UNPAUSE_DELAY_SECONDS:Number = 3;
        public static const DEFAULT_PAUSED_MESSAGE:String = "game paused";
        public static const DEFAULT_UNPAUSING_MESSAGE:String = "unpausing in %(remaining)d...";

        private var _dimBackground:Sprite;
        private var _width:Number;
        private var _height:Number;
        private var _messageLabel:TextField;
        private var _view:Sprite;
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
            trace(printf("creating pause overlay.  delay:%d", delay));

            _delay = delay;
            _pausedMessage = pausedMessage;
            _unpausingMessage = unpausingMessage;

            _unpauseTimer = new Timer(1000, _delay);
            _unpauseTimer.addEventListener(TimerEvent.TIMER, onUnpauseTimer);
            _unpauseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onUnpauseTimerComplete);

            _dimBackground = new Sprite();
            _childViews = new Dictionary();
            _disabledDimViews = new Array(4);
        }

        override public function get height():Number {
            return _height;
        }

        override public function set height(value:Number):void {
            _height = value;
        }

        override public function get width():Number {
            return _width;
        }

        override public function set width(value:Number):void {
            _width = value;
        }

        public function updateSize(h:int, w:int):void {
            trace("updating size to "+w+", "+h);
            height = h;
            width = w;

            refresh();
        }

        public function refresh():void {
            trace("drawing dim background to "+width+", "+height);
            _dimBackground.graphics.clear();
            _dimBackground.graphics.beginFill(0x000000, DIMMED_BACKGROUND_ALPHA);
            _dimBackground.graphics.drawRect(0, 0, width, height);
            _dimBackground.graphics.endFill();
        }

        public function setMessage(value:String):void {
            if (_messageLabel == null) {
                _messageLabel = new TextField();
                var format:TextFormat = new TextFormat("_sans", 32, 0xffffff);
                _messageLabel.defaultTextFormat = format;
                _messageLabel.autoSize = TextFieldAutoSize.LEFT;
                _messageLabel.x = 25;
                _messageLabel.y = 50;
                _dimBackground.addChild(_messageLabel);
            }

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

        private function switchView(view:Sprite):void {
            // do nothing if view hasn't changed
            if (_view == view) {
                return;
            }

            if (_view != null && _view.contains(this)) {
                removeChildren();
                _view.removeChild(this);
            }

            _view = view;

            if (_view != null) {
                updateSize(_view.height, _view.width);
                maybeDimView();
                addChildren();
                _view.addChild(this);
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

        public function pause(view:Sprite):void {
            _unpauseTimer.stop();
            _unpauseTimer.reset();

            var pauseInfo:Object = {
                'delay': _delay,
                'remaining': _delay - _unpauseTimer.currentCount
            };
            var msg:String = printf(_pausedMessage, pauseInfo);
            trace(msg);
            setMessage(msg);
            switchView(view);
        }

        public function unpause(view:Sprite):void {
            if (!_unpauseTimer.running) {
                trace("unpause go!");
                onUnpauseTimer(null);
                _unpauseTimer.start();
            }

            switchView(view);
        }

        protected function onUnpauseTimer(e:TimerEvent):void {
            var unpauseInfo:Object = {
                'delay': _delay,
                'remaining': _delay - _unpauseTimer.currentCount
            };
            var msg:String = printf(_unpausingMessage, unpauseInfo);
            trace(msg);
            setMessage(msg);
        }

        protected function onUnpauseTimerComplete(e:TimerEvent):void {
            switchView(null);
            dispatchEvent(e);
        }
    }
}
