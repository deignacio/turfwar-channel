package com.litl.turfwar {
    public class ArenaPosition {
        private var _x:int;
        private var _y:int;

        public function ArenaPosition(x:int = -1, y:int = -1) {
            _x = x;
            _y = y;
        }

        public function get x():int {
            return _x;
        }

        public function set x(value:int):void {
            _x = value;
        }

        public function get y():int {
            return _y;
        }

        public function set y(value:int):void {
            _y = value;
        }

        public function toString():String {
            return "("+_x+","+_y+")";
        }
    }
}
