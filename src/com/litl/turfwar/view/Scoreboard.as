package com.litl.turfwar.view
{
    import com.litl.control.VerticalList;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.view.ScoreItemRenderer;

    import flash.display.Sprite;

    public class Scoreboard extends Sprite {
        private var _height:int;
        private var _width:int;
        private var _scores:VerticalList;

        public function Scoreboard(model:RemoteControlModel) {
            super();

            height = 500;
            width = 1000;
            x = 100;
            y = 250;

            _scores = new VerticalList();
            _scores.itemRenderer = ScoreItemRenderer;
            _scores.dataProvider = model.scores;
            _scores.verticalScrollPolicy = "off";
            _scores.itemSize = 50;
            _scores.setSize(800, 350);
            _scores.move(50, 50);
            addChild(_scores);
        }

        public function refresh():void {
            _scores.refresh();
        }

        public function destroy():void {
            removeChild(_scores);
            _scores.destroy();
            _scores = null;
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
