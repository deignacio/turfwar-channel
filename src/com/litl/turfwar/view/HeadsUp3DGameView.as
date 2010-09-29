package com.litl.turfwar.view {
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;

    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.RemoteControlVisualiser;

    import flash.display.Sprite;

    public class HeadsUp3DGameView extends View3D implements IGameView {
        private var view:Sprite;
        private var model:RemoteControlModel;
        private var playerRadius:Number;

        public function HeadsUp3DGameView(scene:Scene3D, model:RemoteControlModel, visualiser:RemoteControlVisualiser) {
            this.scene = scene;
            this.model = model;
            this.visualiser = visualiser;

//            topView.x = 350;
//            topView.y = 400;

        }

        protected function resetCamera():void {
            camera.moveTo(model.arena.size.cols * playerRadius, 25 * playerRadius, model.arena.size.rows * playerRadius + 1);
            camera.lookAt(new Vector3D(model.arena.size.cols * playerRadius, -1 * playerRadius, model.arena.size.rows * playerRadius));

            camera.zoom = 2;
        }

        public function clear():void {
            resetCamera();
        }

        public function draw(view:Sprite):void {
            if (view != this.view) {
                this.view = view;
                playerRadius = Math.min(view.width / model.arena.size.cols / 2, view.height / model.arena.size.rows / 2);
            }

            resetCamera();
        }

        public function drawEverything(view:Sprite):void {
            this.view = view;
            playerRadius = Math.min(view.width / model.arena.size.cols / 2, view.height / model.arena.size.rows / 2);

            resetCamera();
        }

        public function crash(playerId:int):void {
            visualiser.doneCrashing(this);
        }
    }
}
