package com.litl.snake.view
{
    import flash.display.Shape;

    public class PlayerShape extends Shape {
        public static const PLAYER_TRAIL_RATIO:Number = 0.5;

        private var _id:int;
        private var _x:Number;
        private var _y:Number;
        public var color:uint;
        public var radius:Number;

        public function PlayerShape(id:int,
                                    color:uint = 0,
                                    x:Number = 0, y:Number = 0,
                                    radius:Number = 0) {
            super();
            _id = id;
            this.color = color;
            _x = x;
            _y = y;
            this.radius = radius;

            redraw();
        }

        public function get id():int {
            return _id;
        }

        override public function get x():Number {
            return _x;
        }

        override public function set x(value:Number):void {
            _x = value;
        }

        override public function get y():Number {
            return _y;
        }

        override public function set y(value:Number):void {
            _y = value;
        }

        public function redraw():void {
            graphics.clear();
            graphics.beginFill(color);
            graphics.drawCircle(x, y, radius);
            graphics.endFill();
        }

        public function makeTailShape():PlayerShape {
            return new PlayerShape(id, color, x, y, radius * PLAYER_TRAIL_RATIO);
        }
    }
}
