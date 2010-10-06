package com.litl.turfwar.view
{
    import com.litl.control.VerticalList;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.view.ScoreItemRenderer;

    import flash.display.Sprite;

    public class Scoreboard extends PausedViewBase {
        private var _scores:VerticalList;

        public function Scoreboard(model:RemoteControlModel) {
            super();

            height = 500;
            width = 500;
            x = 25;
            y = 200;

            _scores = new VerticalList();
            _scores.itemRenderer = ScoreItemRenderer;
            _scores.dataProvider = model.scores;
            _scores.verticalScrollPolicy = "off";
            _scores.itemSize = 50;
            _scores.setSize(350, 350);
            _scores.move(0, 0);
            addChild(_scores);
        }

        override public function refresh():void {
            _scores.refresh();
        }

        public function destroy():void {
            removeChild(_scores);
            _scores.destroy();
            _scores = null;
        }
    }
}
