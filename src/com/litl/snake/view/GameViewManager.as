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
    import com.litl.snake.controls.IGameLoopMember;
    import com.litl.snake.enum.GameLoopStage;
    import com.litl.snake.event.CrashSceneEvent;
    import com.litl.snake.event.SkipStageEvent;
    import com.litl.snake.model.GameModel;

    import flash.events.EventDispatcher;

    [Event(type=SkipStageEvent.SKIP_STAGE, name="com.litl.snake.event.SkipStageEvent")]
    [Event(type=SkipStageEvent.UNSKIP_STAGE, name="com.litl.snake.event.SkipStageEvent")]

    public class GameViewManager extends EventDispatcher implements IGameLoopMember {
        protected var model:GameModel;
        protected var gameViews:Array;
        protected var _view:ViewBase;

        protected var drawingCrashScene:Array;

        public function GameViewManager(model:GameModel) {
            this.model = model;

            gameViews = new Array();
            addGameView(new HeadsUpGameView(model));

            drawingCrashScene = new Array();
        }

        protected function addGameView(gameView:IGameView):void {
            gameView.addEventListener(CrashSceneEvent.BEGIN, onCrashSceneBegin, false, 0, true);
            gameView.addEventListener(CrashSceneEvent.END, onCrashSceneEnd, false, 0, true);

            gameViews.push(gameView);
        }

        public function set view(value:ViewBase):void {
            _view = value;

            forEachGameView(refreshView);
        }

        protected function refreshView(gameView:IGameView):void {
            gameView.view = _view;
            gameView.clear();
            gameView.refresh();
        }

        public function get stages():Array {
            return [GameLoopStage.DRAW];
        }

        public function onStage(stage:String):void {
            switch (stage) {
                case GameLoopStage.DRAW:
                    onDraw();
                    break;
                default:
                    break;
            }
        }

        protected function forEachGameView(func:Function):void {
            var gameView:IGameView;
            for (var i:int = 0; i < gameViews.length; i++) {
                gameView = gameViews[i] as IGameView;
                if (gameView != null) {
                    func(gameView);
                }
            }
        }

        protected function onDraw():void {
            if (model.crashes.length > 0) {
                forEachGameView(drawCrashes);
            } else {
                forEachGameView(drawGameView);
            }
        }

        protected function drawGameView(gameView:IGameView):void {
            gameView.view = _view;
            gameView.drawMove();
        }

        protected function drawCrashes(gameView:IGameView):void {
            gameView.view = _view;
            gameView.drawCrash();
        }

        protected function onCrashSceneBegin(e:CrashSceneEvent):void {
            if (drawingCrashScene.indexOf(e.target) == -1) {
                if (drawingCrashScene.length == 0) {
                    dispatchEvent(new SkipStageEvent(SkipStageEvent.SKIP_STAGE, GameLoopStage.MOVE));
                    dispatchEvent(new SkipStageEvent(SkipStageEvent.SKIP_STAGE, GameLoopStage.DRAW));
                }

                drawingCrashScene.push(e.target);
            }
        }

        protected function onCrashSceneEnd(e:CrashSceneEvent):void {
            var crashing:IGameView = e.target as IGameView;
            var index:int = drawingCrashScene.indexOf(crashing);
            if (index != -1) {
                drawingCrashScene.splice(index, 1);
                if (drawingCrashScene.length == 0) {
                    dispatchEvent(new SkipStageEvent(SkipStageEvent.UNSKIP_STAGE, GameLoopStage.MOVE));
                    dispatchEvent(new SkipStageEvent(SkipStageEvent.UNSKIP_STAGE, GameLoopStage.DRAW));

                    forEachGameView(refreshView);
                }
            }

        }
    }
}
