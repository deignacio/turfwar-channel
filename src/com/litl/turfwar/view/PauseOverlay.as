package com.litl.turfwar.view
{
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Timer;

    import printf;

    public class PauseOverlay extends Sprite {
        public static const DIMMED_BACKGROUND_ALPHA:Number = 0.75;
        public static const DEFAULT_UNPAUSE_DELAY_SECONDS:Number = 3;
        public static const DEFAULT_PAUSED_MESSAGE:String = "game paused";
        public static const DEFAULT_UNPAUSING_MESSAGE:String = "unpausing in %(remaining)d...";

        private var _width:Number;
        private var _height:Number;
        private var _messageLabel:TextField;
        private var _view:Sprite;
        private var _unpauseTimer:Timer;

        private var _delay:Number;
        private var _pausedMessage:String;
        private var _unpausingMessage:String;

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
            graphics.clear();
            graphics.beginFill(0x000000, DIMMED_BACKGROUND_ALPHA);
            graphics.drawRect(0, 0, width, height);
            graphics.endFill();
        }

        public function setMessage(value:String):void {
            if (_messageLabel == null) {
                _messageLabel = new TextField();
                var format:TextFormat = new TextFormat("_sans", 32, 0xffffff);
                _messageLabel.defaultTextFormat = format;
                _messageLabel.autoSize = TextFieldAutoSize.LEFT;
                _messageLabel.x = 25;
                _messageLabel.y = 50;
                addChild(_messageLabel);
            }

            _messageLabel.text = value;
        }

        private function switchView(view:Sprite):void {
            // do nothing if view hasn't changed
            if (_view == view) {
                return;
            }

            if (_view != null && _view.contains(this)) {
                _view.removeChild(this);
            }

            _view = view;

            if (_view != null) {
                updateSize(_view.height, _view.width);
                _view.addChild(this);
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
