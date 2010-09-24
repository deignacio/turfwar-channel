package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;

    public class RemoteControlVisualiser {
        protected var dataModel:RemoteControlModel;
        protected var screenHeight:Number;
        protected var screenWidth:Number;
        protected var view:Sprite;

        public static const PLAYER_TRAIL_RATIO:Number = 0.5;
        private var playerRadius:Number;
        private var trailRadius:Number;

        private var colors:Array = [ 0x000000, 0x9AD7DB, 0xFFFFFF, 0x00ff00,
            0xff0000, 0x76d5db, 0x56d3db,
            0x2cd0db, 0x00cedb, 0x00cedb ];

        public function RemoteControlVisualiser(dataModel:RemoteControlModel) {
            this.dataModel = dataModel;
            dataModel.addEventListener("crashed", onCrash);
        }

        protected function onCrash(e:Event):void {
            clearScreen();
        }

        protected function clearScreen():void {
            var s:Shape = new Shape();
            s.graphics.clear();
            s.graphics.beginFill(0x000000);
            s.graphics.drawRect(0, 0, view.width, view.height);
            s.graphics.endFill();
            view.addChild(s);
        }

        public function drawGame(view:Sprite):void {
            if (this.view != view) {
                this.view = view;
                playerRadius = Math.min(view.width / dataModel.arena.size.cols / 2, view.height / dataModel.arena.size.rows / 2);
                trailRadius = playerRadius * PLAYER_TRAIL_RATIO;
            }

            dataModel.forEachPlayer(drawTrail);
            dataModel.forEachPlayer(drawPlayer);
        }

        public function drawWholeGame(view:Sprite):void {
            this.view = view;
            playerRadius = Math.min(view.width / dataModel.arena.size.cols / 2, view.height / dataModel.arena.size.rows / 2);
            trailRadius = playerRadius * PLAYER_TRAIL_RATIO;

            clearScreen();
            drawArena(dataModel.arena);
        }

        protected function drawPlayer(player:Player):void {
            var color:uint = colors[player.id % colors.length];
            var s:Shape = new Shape();
            s.graphics.clear();
            s.graphics.beginFill(color);
            s.graphics.drawCircle(getScreenPositionX(player.position),
                getScreenPositionY(player.position), playerRadius);
            s.graphics.endFill();
            view.addChild(s);
        }

        protected function drawTrail(player:Player):void {
            var pos:ArenaPosition = dataModel.arena.getTrailPosition(player);
            var color:uint = colors[player.id % colors.length];
            drawTrailForPosition(pos, color);
        }

        protected function redrawTrailForPosition(player:Player, pos:ArenaPosition):void {
            var color:uint = colors[player.id % colors.length];
            drawTrailForPosition(pos, color);
        }

        protected function drawTrailForPosition(pos:ArenaPosition, color:uint):void {
            var s:Shape = new Shape();
            s.graphics.clear();
            s.graphics.beginFill(0x000000);
            s.graphics.drawCircle(getScreenPositionX(pos),
                                  getScreenPositionY(pos), playerRadius);
            s.graphics.endFill();
            s.graphics.beginFill(color);
            s.graphics.drawCircle(getScreenPositionX(pos),
                                  getScreenPositionY(pos), trailRadius);
            s.graphics.endFill();
            view.addChild(s);
        }

        protected function getScreenPositionX(pos:ArenaPosition):int {
            return pos.x * playerRadius * 2;
        }

        protected function getScreenPositionY(pos:ArenaPosition):int {
            return pos.y * playerRadius * 2;
        }

        protected function drawArena(arena:ArenaModel):void {
            dataModel.arena.forEachSpot(redrawTrailForPosition);
        }
    }
}
