package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.util.Tween;
    import com.litl.turfwar.event.CrashEvent;
    import com.litl.turfwar.view.PlayerShape;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.Dictionary;

    public class RemoteControlVisualiser {
        protected var dataModel:RemoteControlModel;
        protected var screenHeight:Number;
        protected var screenWidth:Number;
        protected var view:Sprite;

        public static const PLAYER_TRAIL_RATIO:Number = 0.5;
        private var playerRadius:Number;
        private var trailRadius:Number;
        private var maxDist:Number;

        private var playerShapes:Dictionary;
        private var crashedPlayerId:int;
        private var explodeTweens:Array;

        private var colors:Array = [ 0x000000, 0x9AD7DB, 0xFFFFFF, 0x00ff00,
            0xff0000, 0x76d5db, 0x56d3db,
            0x2cd0db, 0x00cedb, 0x00cedb ];

        public function RemoteControlVisualiser(dataModel:RemoteControlModel) {
            playerShapes = new Dictionary();
            explodeTweens = new Array();
            this.dataModel = dataModel;
            dataModel.addEventListener(CrashEvent.CRASH, onCrash);
        }

        protected function onCrash(e:CrashEvent):void {
            crashedPlayerId = e.player.id;
            dataModel.arena.forEachSpot(explodeSpot);
            dataModel.forEachPlayer(explodePlayer);
            crashPlayer();
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
                maxDist = Math.sqrt(view.width * view.width + view.height * view.height);
            }

            dataModel.forEachPlayer(drawTrailForPlayer);
            dataModel.forEachPlayer(drawPlayer);
        }

        public function drawWholeGame(view:Sprite):void {
            this.view = view;
            playerRadius = Math.min(view.width / dataModel.arena.size.cols / 2, view.height / dataModel.arena.size.rows / 2);
            trailRadius = playerRadius * PLAYER_TRAIL_RATIO;
            maxDist = Math.sqrt(view.width * view.width + view.height * view.height);

            clearScreen();
            drawArena(dataModel.arena);
        }

        protected function crashPlayer():void {
            var crash:Tween = Tween.tweenTo(playerShapes[crashedPlayerId],
                                            2,
                                            { "radius":20*playerRadius,
                                              "alpha":0.0 });
            crash.addEventListener("complete", onCrashComplete);
            explodeTweens.push(crash);
        }

        protected function explodePlayer(player:Player):void {
            if (player.id == crashedPlayerId) {
                return;
            }

            var crashParams:Object = calculateExplodeDestination(playerShapes[player.id]);
            crashParams["alpha"] = 0.5;
            var explode:Tween = Tween.tweenTo(playerShapes[player.id],
                                              2, crashParams);

            explode.addEventListener("complete", onExplodeComplete);
            explodeTweens.push(explode);
        }

        protected function explodeSpot(shape:PlayerShape):void {
            var crashParams:Object = calculateExplodeDestination(shape);
            crashParams["alpha"] = 0.0;
            var explode:Tween = Tween.tweenTo(shape,
                                              1.5, crashParams);
            explode.addEventListener("complete", onExplodeComplete);
            explodeTweens.push(explode);
        }

        protected function onCrashComplete(e:Event):void {
            var tween:Tween = e.currentTarget as Tween;
            explodeTweens.splice(explodeTweens.indexOf(tween), 1);
            maybeRestart();
        }

        protected function onExplodeComplete(e:Event):void {
            var tween:Tween = e.currentTarget as Tween;
            explodeTweens.splice(explodeTweens.indexOf(tween), 1);
            maybeRestart();
        }

        private function maybeRestart():void {
            if (explodeTweens.length == 0) {
                clearScreen();
                playerShapes = new Dictionary();
                dataModel.unpause();
            }
        }

        protected function drawPlayer(player:Player):void {
            if (!playerShapes.hasOwnProperty(player.id)) {
                playerShapes[player.id] = new PlayerShape(player.id, player.position,
                                                          colors[player.id % colors.length],
                                                          0,
                                                          0,
                                                          playerRadius);
            }

            var s:PlayerShape = playerShapes[player.id];
            s.position = player.position;
            s.freeze();
            mapShapeToScreen(s);
            s.thaw();
            if (view.contains(s)) {
                view.removeChild(s);
            }
            view.addChild(s);
        }

        protected function drawTrailForPlayer(player:Player):void {
            var shape:PlayerShape = dataModel.arena.getTrailShape(player);
            if (shape != null) {
                redrawTrailShape(shape);
            }
        }

        protected function redrawTrailShape(shape:PlayerShape):void {
            var color:uint = colors[shape.id % colors.length];
            shape.freeze();
            shape.color = color;
            mapShapeToScreen(shape);
            shape.radius = trailRadius;
            shape.thaw();

            if (!view.contains(shape)) {
                view.addChild(shape);
            }
        }

        protected function mapShapeToScreen(s:PlayerShape):void {
            s.x = s.position.x * playerRadius * 2;
            s.y = s.position.y * playerRadius * 2;
        }

        protected function calculateExplodeDestination(s:PlayerShape):Object {
            var crashed:PlayerShape = playerShapes[crashedPlayerId];
            var proximity:Number = Math.sqrt(Math.pow(crashed.x - s.x, 2) + Math.pow(crashed.y - s.y, 2));
            var ratio:Number = maxDist / proximity - 1;

            var dx:Number = ratio * (crashed.x - s.x);
            var dy:Number = ratio * (crashed.y - s.y);

            var dest:Object = { "x":crashed.x - dx, "y":crashed.y - dy };
            return dest;
        }

        protected function drawArena(arena:ArenaModel):void {
            dataModel.arena.forEachSpot(redrawTrailShape);
        }
    }
}
