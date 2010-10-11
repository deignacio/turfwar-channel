/* Copyright (c) 2010 litl, LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to
* deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
* sell copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/
package com.litl.snake.view {
    import com.litl.helpers.view.ViewBase;
    import com.litl.sdk.util.Tween;
    import com.litl.snake.enum.PlayerColors;
    import com.litl.snake.event.CrashSceneEvent;
    import com.litl.snake.model.GameModel;
    import com.litl.snake.model.Player;
    import com.litl.snake.model.PlayerPosition;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;

    [Event(name=CrashSceneEvent.BEGIN, type="com.litl.snake.event.CrashSceneEvent")]
    [Event(name=CrashSceneEvent.END, type="com.litl.snake.event.CrashSceneEvent")]

    public class HeadsUpGameView extends EventDispatcher implements IGameView {
        public static const ARENA_COLOR:uint = 0x000000;
        public static const BACKGROUND_COLOR:uint = 0xcdc9c9;

        private var model:GameModel;
        private var _view:ViewBase;
        private var sprite:Sprite;
        private var background:Shape;
        protected var playerShapes:Dictionary;
        protected var tails:Sprite

        protected var playerRadius:Number;
        protected var maxDist:Number;

        protected var explodeCenter:Object;
        protected var explodeTweens:Array;

        public function HeadsUpGameView(model:GameModel) {
            this.model = model;

            playerShapes = new Dictionary();
            explodeTweens = new Array();

            sprite = new Sprite();
        }

        public function set view(value:ViewBase):void {
            if (_view != value) {
                _view = value;

                _view.addChild(sprite);

                playerRadius = Math.min(_view.width / model.arena.size.cols / 2, _view.height / model.arena.size.rows / 2);
                maxDist = Math.sqrt(Math.pow(_view.width, 2) + Math.pow(_view.height, 2));
            }
        }

        public function clear():void {
            if (background != null && background.parent != null) {
                background.parent.removeChild(background);
            }

            background = new Shape();
            background.graphics.clear();
            background.graphics.beginFill(BACKGROUND_COLOR);
            background.graphics.drawRect(0, 0, _view.width, _view.height);
            background.graphics.endFill();
            background.graphics.beginFill(ARENA_COLOR);
            background.graphics.drawRect(0, 0, model.arena.size.cols * playerRadius * 2, model.arena.size.rows * playerRadius * 2);
            background.graphics.endFill();
            sprite.addChild(background);

            if (tails != null && tails.parent != null) {
                tails.parent.removeChild(tails);
            }

            tails = new Sprite();
            sprite.addChild(tails);
        }

        public function drawMove():void {
            model.forEachPlayer(drawPlayer);
        }

        public function refresh():void {
            model.arena.forEachPosition(drawTail);
        }

        protected function drawPlayer(player:Player):void {
            if (!playerShapes.hasOwnProperty(player.id)) {
                playerShapes[player.id] = new PlayerShape(player.id,
                    PlayerColors.getColor(player.id),
                    0,
                    0,
                    playerRadius);
            }

            var s:PlayerShape = playerShapes[player.id];
            mapToScreen(s, player.position);
            s.redraw();
            sprite.addChild(s);
            tails.addChild(s.makeTailShape());
        }

        protected function drawTail(pos:PlayerPosition, player:Player):void {
            var s:PlayerShape = playerShapes[player.id];
            if (s != null) {
                mapToScreen(s, pos);
                tails.addChild(s.makeTailShape());
            }
        }

        protected function mapToScreen(obj:Object, pos:PlayerPosition):void {
            obj.x = pos.x * playerRadius * 2;
            obj.y = pos.y * playerRadius * 2;
        }

        public function drawCrash():void {
            dispatchEvent(new CrashSceneEvent(CrashSceneEvent.BEGIN));

            explodeCenter = calculateExplodeCenter();

            var t:PlayerShape;
            for (var i:int = 0; i < tails.numChildren; i++) {
                t = tails.getChildAt(i) as PlayerShape;
                explodePlayerShape(t);
            }

            model.forEachPlayer(crashOrExplodePlayer);

            explodeCenter = null;
        }

        protected function crashOrExplodePlayer(player:Player):void {
            var shape:PlayerShape = playerShapes[player.id];
            if (model.crashes.indexOf(player) != -1) {
                crashPlayerShape(shape);
                delete playerShapes[player.id];
            } else {
                explodePlayerShape(shape);
            }
        }

        protected function crashPlayerShape(s:PlayerShape):void {
            var tween:Tween = Tween.tweenTo(s,
                2,
                { "radius":20*playerRadius,
                    "alpha":0.0 });
            tween.addEventListener("complete", onExplodeComplete);
            explodeTweens.push(tween);
        }

        protected function explodePlayerShape(s:PlayerShape):void {
            var crashParams:Object = calculateExplodeDestination(s, explodeCenter);
            crashParams["alpha"] = 0.0;
            var explode:Tween = Tween.tweenTo(s,
                1.5, crashParams);
            explode.addEventListener("complete", onExplodeComplete);
            explodeTweens.push(explode);
        }

        protected function onExplodeComplete(e:Event):void {
            var tween:Tween = e.currentTarget as Tween;
            var index:int = explodeTweens.indexOf(tween);
            if (index != -1) {
                explodeTweens.splice(index, 1);
            }
            maybeDoneCrashing();
        }

        protected function maybeDoneCrashing():void {
            if (explodeTweens.length == 0) {
                dispatchEvent(new CrashSceneEvent(CrashSceneEvent.END));
            }
        }

        protected function calculateExplodeCenter():Object {
            var center:PlayerPosition = new PlayerPosition(0, 0);

            var p:Player;
            for (var i:int = 0; i < model.crashes.length; i++) {
                p = model.crashes[i];
                center.x += p.position.x;
                center.y += p.position.y;
            }

            center.x /= model.crashes.length;
            center.y /= model.crashes.length;

            var obj:Object = {};
            mapToScreen(obj, center);
            return obj;
        }

        protected function calculateExplodeDestination(s:PlayerShape, center:Object):Object {
            var proximity:Number = Math.sqrt(Math.pow(center.x - s.x, 2) + Math.pow(center.y - s.y, 2));
            var ratio:Number = maxDist / proximity;
            var dx:Number = ratio * (center.x - s.x);
            var dy:Number = ratio * (center.y - s.y);

            var dest:Object = { "x":center.x - dx, "y":center.y - dy };
            return dest;
        }
    }
}
