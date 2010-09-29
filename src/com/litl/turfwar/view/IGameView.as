package com.litl.turfwar.view {
    import flash.display.Sprite;

    public interface IGameView {
        function clear():void;
        function draw(view:Sprite):void;
        function drawEverything(view:Sprite):void;
        function crash(playerId:int):void;
        function destroy():void;
    }
}
