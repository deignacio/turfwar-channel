package com.litl.turfwar.view {
    import com.litl.sdk.util.Tween;
    import com.litl.turfwar.Player;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.RemoteControlVisualiser;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.Dictionary;

    public class HeadsUpGameView implements IGameView {
        public static const ARENA_COLOR:uint = 0x000000;
        public static const BACKGROUND_COLOR:uint = 0xcdc9c9;
        public static const PLAYER_TRAIL_RATIO:Number = 0.5;

        private var playerShapes:Dictionary;
        private var crashedPlayerId:int;
        private var explodeTweens:Array;

        private var sprite:Sprite;
        private var wRatio:Number;
        private var hRatio:Number;
        private var xRatio:Number;
        private var yRatio:Number;

        private var _view:Sprite;
        private var playerRadius:Number;
        private var trailRadius:Number;
        private var maxDist:Number;

        private var model:RemoteControlModel;
        private var visualiser:RemoteControlVisualiser;

        private var _destroyed:Boolean = false;

        public function HeadsUpGameView(model:RemoteControlModel, visualiser:RemoteControlVisualiser,
                                        widthRatio:Number = 1, heightRatio:Number = 1, xRatio:Number = 0, yRatio:Number = 0) {
            playerShapes = new Dictionary();
            explodeTweens = new Array();

            sprite = new Sprite();
            this.wRatio = widthRatio;
            this.hRatio = heightRatio;
            this.xRatio = xRatio;
            this.yRatio = yRatio;

            this.model = model;
            this.visualiser = visualiser;
        }

        protected function get view():Sprite {
            return _view;
        }

        protected function set view(value:Sprite):void {
            if (value != view) {
                _view = value;
                view.addChild(sprite);

                trace("hud sprite:  ("+sprite.x+","+sprite.y+")  "+sprite.width+"x"+sprite.height+" vs "+view.width+"x"+view.height);
                playerRadius = Math.min(view.width * wRatio / model.arena.size.cols / 2, view.height * hRatio / model.arena.size.rows / 2);
                trailRadius = playerRadius * PLAYER_TRAIL_RATIO;
                maxDist = Math.sqrt(sprite.width * sprite.width + sprite.height * sprite.height);
            }
        }

        public function destroy():void {
            _destroyed = true;
        }

        public function clear():void {
            trace("hud view clear");
            var s:Shape = new Shape();
            s.graphics.clear();
            s.graphics.beginFill(BACKGROUND_COLOR);
            s.graphics.drawRect(0, 0, view.width * wRatio, view.height * hRatio);
            s.graphics.endFill();
            s.graphics.beginFill(ARENA_COLOR);
            s.graphics.drawRect(0, 0, model.arena.size.cols * playerRadius * 2, model.arena.size.rows * playerRadius * 2);
            s.graphics.endFill();
            sprite.addChild(s);
        }

        public function crash(playerId:int):void {
            crashedPlayerId = playerId;
            model.arena.forEachSpot(explodeSpot);
            model.forEachPlayer(explodePlayer);
            crashPlayer();
        }

        public function draw(view:Sprite):void {
            this.view = view;

            model.forEachPlayer(drawTrailForPlayer);
            model.forEachPlayer(drawPlayer);
        }

        public function drawEverything(view:Sprite):void {
            this.view = view;

            clear();

            model.arena.forEachSpot(redrawTrailShape);
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
                playerShapes = new Dictionary();
                visualiser.doneCrashing(this);
            }
        }

        protected function drawPlayer(player:Player):void {
            if (!playerShapes.hasOwnProperty(player.id)) {
                playerShapes[player.id] = new PlayerShape(player.id, player.position,
                    RemoteControlVisualiser.getColor(player.id),
                    0,
                    0,
                    playerRadius);
            }

            var s:PlayerShape = playerShapes[player.id];
            s.position = player.position;
            s.freeze();
            mapShapeToScreen(s);
            s.thaw();
            sprite.addChild(s);
        }

        protected function drawTrailForPlayer(player:Player):void {
            var shape:PlayerShape = model.arena.getTrailShape(player);
            if (shape != null) {
                redrawTrailShape(shape);
            }
        }

        protected function redrawTrailShape(shape:PlayerShape):void {
            var color:uint = RemoteControlVisualiser.getColor(shape.id);
            shape.freeze();
            shape.color = color;
            mapShapeToScreen(shape);
            shape.radius = trailRadius;
            shape.thaw();

            sprite.addChild(shape);
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
    }
}
