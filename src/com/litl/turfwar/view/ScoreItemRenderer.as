package com.litl.turfwar.view
{
    import com.litl.control.ControlBase;
    import com.litl.control.listclasses.IItemRenderer;

    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;

    public class ScoreItemRenderer extends ControlBase implements IItemRenderer {

        protected var _data:Object;
        protected var nameField:TextField;
        protected var scoresField:TextField;

        protected var background:Sprite;

        override protected function createChildren():void {
            mouseChildren = false;

            background = new Sprite();
            addChild(background);

            nameField = new TextField();
            var tfm:TextFormat = new TextFormat("CorpoS", 18, 0xffffff, false);
            tfm.align = TextFormatAlign.LEFT;
            nameField.defaultTextFormat = tfm;
            nameField.wordWrap = true;
            //textField.embedFonts = true;
            nameField.multiline = true;
            nameField.selectable = false;
            nameField.antiAliasType = "advanced";
            nameField.gridFitType = "pixel";
            nameField.autoSize = TextFieldAutoSize.CENTER;
            addChild(nameField);

            scoresField = new TextField();
            tfm = new TextFormat("CorpoS", 14, 0xffffff, false);
            tfm.align = TextFormatAlign.LEFT;
            scoresField.defaultTextFormat = tfm;
            scoresField.wordWrap = true;
            //textField.embedFonts = true;
            scoresField.multiline = true;
            scoresField.selectable = false;
            scoresField.antiAliasType = "advanced";
            scoresField.gridFitType = "pixel";
            scoresField.autoSize = TextFieldAutoSize.CENTER;
            addChild(scoresField);
        }

        override protected function updateProperties():void {
            if (nameField != null)
                nameField.text = _data == null ? "" : _data.name;
            if (scoresField != null)
                scoresField.text = _data == null ? "" : _data.score;
        }

        override protected function layout():void {
            if (_width > 0 && _height > 0) {
                graphics.clear();

                var backgroundColor:uint = myStyles.backgroundColor == undefined ? 0 : myStyles.backgroundColor;
                graphics.beginFill(backgroundColor, 1);
                graphics.drawRect(0, 0, _width, _height);
                graphics.endFill();
            }

            var fontColor:uint = myStyles.color == undefined ? 0xffffff : myStyles.color;
            var tfm:TextFormat = nameField.defaultTextFormat;
            tfm.color = fontColor;
            nameField.defaultTextFormat = tfm;
            nameField.setTextFormat(tfm);
            nameField.width = _width * 0.5 - 8;
            nameField.y = Math.floor((_height - nameField.height) / 2);
            nameField.x = 8;

            scoresField.defaultTextFormat = tfm;
            scoresField.setTextFormat(tfm);
            scoresField.width = _width * 0.5 - 8;
            scoresField.y = Math.floor((_height - scoresField.height) / 2);
            scoresField.x = nameField.width + 16;
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
