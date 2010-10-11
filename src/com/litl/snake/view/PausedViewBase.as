package com.litl.snake.view {
    import flash.display.Sprite;

    /**
     * Extend the PausedViewBase class for views that are intended
     * to be shown as a child of the PauseOverlay.  Be sure to override
     * the refresh method, as it will be called before the overlay
     * is shown each time.
     *
     * @see com.litl.turfwar.view.PauseOverlay
     */
    public class PausedViewBase extends Sprite {
        private var _height:int;
        private var _width:int;

        public function PausedViewBase() {
            super();
        }

        /**
         * called by the pause overlay before adding this
         * object to it's view.  meant to update
         * any data or displays that might have changed
         * since the last time it was shown.
         */
        public function refresh():void {
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
    }
}
