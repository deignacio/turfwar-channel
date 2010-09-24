package com.litl.turfwar.view
{
    import com.litl.turfwar.ArenaPosition;

    import flash.display.Shape;

    public class PlayerShape extends Shape {
        private var _id:int;
        private var _pos:ArenaPosition;
        private var _x:Number;
        private var _y:Number;
        private var _color:uint;
        private var _radius:Number;

        private var _frozen:Boolean = false;

        public function PlayerShape(id:int, pos:ArenaPosition,
                                    color:uint = 0,
                                    x:Number = 0, y:Number = 0,
                                    radius:Number = 0) {
            super();
            _id = id;
            _pos = pos;
            _color = color;
            _x = x;
            _y = y;
            _radius = radius;

            redraw();
        }

        public function freeze():void {
            _frozen = true;
        }

        public function thaw():void {
            _frozen = false;
            redraw();
        }

        public function get id():int {
            return _id;
        }

        public function get position():ArenaPosition {
            return _pos;
        }

        public function set position(value:ArenaPosition):void {
            _pos = value;
        }

        protected function redraw():void {
            if (_frozen) {
                return;
            }

            graphics.clear();
            graphics.beginFill(_color);
            graphics.drawCircle(_x, _y, _radius);
            graphics.endFill();
        }

        override public function get x():Number {
            return _x;
        }

        override public function set x(value:Number):void {
            if (_x!= value) {
                _x = value;
                redraw();
            }
        }

        override public function get y():Number {
            return _y;
        }

        override public function set y(value:Number):void {
            if (_y!= value) {
                _y = value;
                redraw();
            }
        }

        public function get color():uint {
            return _color;
        }

        public function set color(value:uint):void {
            if (_color!= value) {
                _color = value;
                redraw();
            }
        }

        public function get radius():Number {
            return _radius;
        }

        public function set radius(value:Number):void {
            if (_radius!= value) {
                _radius = value;
                redraw();
            }
        }
    }
}
