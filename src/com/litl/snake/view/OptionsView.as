package com.litl.snake.view {
    import com.litl.control.Label;
    import com.litl.control.TextButton;
    import com.litl.control.VerticalList;
    import com.litl.snake.controls.GameLoop;
    import com.litl.snake.enum.ArenaSize;
    import com.litl.snake.enum.ArenaWrap;
    import com.litl.snake.enum.GameSpeed;
    import com.litl.snake.model.GameModel;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class OptionsView extends PausedViewBase {
        private var background:Shape;
        private var gameLoop:GameLoop;
        private var model:GameModel;

        private var sizeList:VerticalList;
        private var speedList:VerticalList;
        private var wrapList:VerticalList;

        public function OptionsView(gameLoop:GameLoop, model:GameModel) {
            super();
            height = 400;
            width = 225;
            x = 450;
            y = 30;

            this.gameLoop = gameLoop;
            this.model = model;

            background = new Shape();
            background.graphics.beginFill(0x000000);
            background.graphics.drawRect(0, 0, width, height);
            background.graphics.endFill();
            addChild(background);

            var label:Label = new Label();
            label.text = "game options";
            label.move(25, 20);
            addChild(label);

            label = new Label();
            label.text = "arena size";
            label.move(50, 50);
            addChild(label);

            sizeList = new VerticalList();
            sizeList.verticalScrollPolicy = "off";
            sizeList.itemSize = 20;
            sizeList.setSize(100, 80);
            sizeList.move(50, 70);
            addChild(sizeList);
            sizeList.dataProvider = ArenaSize.ALL_SIZES;
            sizeList.addEventListener(Event.SELECT, onSizeSelect, false, 0, true);

            label = new Label();
            label.text = "game speed";
            label.move(50, 175);
            addChild(label);

            speedList = new VerticalList();
            speedList.verticalScrollPolicy = "off";
            speedList.itemSize = 20;
            speedList.setSize(100, 80);
            speedList.move(50, 195);
            addChild(speedList);
            speedList.dataProvider = GameSpeed.ALL_SPEEDS;
            speedList.addEventListener(Event.SELECT, onSpeedSelect, false, 0, true);

            label = new Label();
            label.text = "wall wrap";
            label.move(50, 305);
            addChild(label);

            wrapList = new VerticalList();
            wrapList.verticalScrollPolicy = "off";
            wrapList.itemSize = 20;
            wrapList.setSize(150, 50);
            wrapList.move(50, 325);
            addChild(wrapList);
            wrapList.dataProvider = ArenaWrap.ALL_WRAPS;
            wrapList.addEventListener(Event.SELECT, onWrapSelect, false, 0, true);

            refresh();
        }

        protected function onSizeSelect(e:Event):void {
            var size:ArenaSize = sizeList.selectedItem as ArenaSize;
            model.arena.size = size;
        }

        protected function onSpeedSelect(e:Event):void {
            var speed:GameSpeed = speedList.selectedItem as GameSpeed;
            gameLoop.speed = speed;
        }

        protected function onWrapSelect(e:Event):void {
            var wrap:ArenaWrap = wrapList.selectedItem as ArenaWrap;
            model.arena.wrap = wrap;
        }

        override public function refresh():void {
            sizeList.selectedIndex = ArenaSize.ALL_SIZES.indexOf(model.arena.size);
            speedList.selectedIndex = GameSpeed.ALL_SPEEDS.indexOf(gameLoop.speed);
            wrapList.selectedIndex = ArenaWrap.ALL_WRAPS.indexOf(model.arena.wrap);
        }
    }
}
