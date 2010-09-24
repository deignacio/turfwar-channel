package com.litl.turfwar.view {
    import com.litl.control.TextButton;
    import com.litl.control.VerticalList;
    import com.litl.sdk.service.LitlService;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.enum.ArenaSize;
    import com.litl.turfwar.enum.GameSpeed;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;

    public class OptionsView extends Sprite {
        private var _height:int;
        private var _width:int;
        private var _shape:Shape;
        private var _model:RemoteControlModel;
        private var _closeButton:TextButton;
        private var _service:LitlService;

        private var _sizes:VerticalList;
        private var _speeds:VerticalList;

        public function OptionsView(model:RemoteControlModel, service:LitlService) {
            super();
            height = 600;
            width = 500;
            x = 300;
            y = 0;

            _model = model;
            _service = service;

            _shape = new Shape();
            _shape.graphics.beginFill(0x000000);
            _shape.graphics.drawRect(0, 0, width, height);
            _shape.graphics.endFill();
            addChild(_shape);

            _closeButton = new TextButton();
            _closeButton.text = "close";
            _closeButton.move(400, 425);
            _closeButton.styleName = ".mainButton";
            _closeButton.addEventListener(MouseEvent.CLICK, onCloseClicked);
            addChild(_closeButton);

            _sizes = new VerticalList();
            _sizes.verticalScrollPolicy = "off";
            _sizes.itemSize = 20;
            _sizes.setSize(100, 80);
            _sizes.move(100, 50);
            addChild(_sizes);
            _sizes.dataProvider = ArenaSize.ALL_SIZES;
            _sizes.selectedIndex = ArenaSize.ALL_SIZES.indexOf(_model.arena.size);
            _sizes.addEventListener(Event.SELECT, onSizeSelect, false, 0, true);

            _speeds = new VerticalList();
            _speeds.verticalScrollPolicy = "off";
            _speeds.itemSize = 20;
            _speeds.setSize(100, 80);
            _speeds.move(100, 175);
            addChild(_speeds);
            _speeds.dataProvider = GameSpeed.ALL_SPEEDS;
            _speeds.selectedIndex = GameSpeed.ALL_SPEEDS.indexOf(_model.speed);
            _speeds.addEventListener(Event.SELECT, onSpeedSelect, false, 0, true);
        }

        public function onCloseClicked(e:MouseEvent):void {
            _service.closeOptions();
        }

        public function onSizeSelect(e:Event):void {
            var size:ArenaSize = _sizes.selectedItem as ArenaSize;
            _model.arena.size = size;
        }

        public function onSpeedSelect(e:Event):void {
            var speed:GameSpeed = _speeds.selectedItem as GameSpeed;
            _model.speed = speed;
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
