package com.litl.snake.view
{
    import com.litl.control.ControlBase;
    import com.litl.control.Label;
    import com.litl.control.listclasses.IItemRenderer;

    import flash.display.Sprite;
    import flash.text.TextFieldAutoSize;

    public class ScoreItemRenderer extends ControlBase implements IItemRenderer {

        protected var _data:Object;
        protected var nameLabel:Label;
        protected var scoreLabel:Label;

        protected var background:Sprite;

        override protected function createChildren():void {
            mouseChildren = false;

            background = new Sprite();
            addChild(background);

            nameLabel = new Label();
            nameLabel.autoSize = TextFieldAutoSize.LEFT;
            addChild(nameLabel);

            scoreLabel = new Label();
            scoreLabel.autoSize = TextFieldAutoSize.LEFT;
            addChild(scoreLabel);
        }

        override protected function updateProperties():void {
            var name:String = _data == null ? "" : _data.name;
            var score:String = _data == null ? "" : "crashed: " + _data.crashCount + ", caused: "+ _data.causedCount;

            if (nameLabel != null) {
                nameLabel.text = name;
            }

            if (scoreLabel != null) {
                scoreLabel.text = score;
            }
        }

        override protected function layout():void {
            if (_width > 0 && _height > 0) {
                graphics.clear();

                var backgroundColor:uint = myStyles.backgroundColor == undefined ? 0 : myStyles.backgroundColor;
                graphics.beginFill(backgroundColor, 1);
                graphics.drawRect(0, 0, _width, _height);
                graphics.endFill();
            }

            nameLabel.width = _width * 0.4 - 8;
            nameLabel.move(8, Math.floor((_height - nameLabel.height) / 2));

            scoreLabel.width = _width * 0.6 - 8;
            scoreLabel.move(nameLabel.width + 16, Math.floor((_height - scoreLabel.height) / 2));
        }

        public function get data():Object {
            return _data;
        }

        public function set data(value:Object):void {
            _data = value;

            invalidateProperties();
        }

        public function set enabled(b:Boolean):void {
            alpha = b ? 1 : 0.75;
        }

        public function set selected(b:Boolean):void {
        }

        public function get selected():Boolean {
            return false;
        }

        public function get isReady():Boolean {
            return true;
        }
    }
}
