package com.litl.turfwar.view {
    import away3d.containers.ObjectContainer3D;
    import away3d.containers.Scene3D;
    import away3d.containers.View3D;
    import away3d.core.base.Object3D;
    import away3d.materials.WireColorMaterial;
    import away3d.primitives.Cylinder;
    import away3d.primitives.Plane;
    import away3d.primitives.Sphere;

    import com.litl.turfwar.ArenaPosition;
    import com.litl.turfwar.Player;
    import com.litl.turfwar.PlayerMove;
    import com.litl.turfwar.RemoteControlModel;
    import com.litl.turfwar.RemoteControlVisualiser;
    import com.litl.turfwar.enum.ArenaDirection;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.geom.Vector3D;

    public class FirstPersonView implements IGameView {
        private var visualiser:RemoteControlVisualiser
        private var model:RemoteControlModel;
        private var sprite:Sprite;
        private var wRatio:Number;
        private var hRatio:Number;
        private var xRatio:Number;
        private var yRatio:Number;

        private var view3d:View3D;
        private var _view:Sprite;
        private var playerRadius:Number;

        private var player:Player;
        private var head:Sphere;
        private var cont:ObjectContainer3D;
        private var walls:ObjectContainer3D;

        private var _destroyed:Boolean = false;

        public function FirstPersonView(player:Player, model:RemoteControlModel, visualiser:RemoteControlVisualiser,
                                        widthRatio:Number = 1, heightRatio:Number = 1, xRatio:Number = 0, yRatio:Number = 0) {
            this.player = player;
            this.model = model;
            this.visualiser = visualiser;

            sprite = new Sprite();
            this.wRatio = widthRatio;
            this.hRatio = heightRatio;
            this.xRatio = xRatio;
            this.yRatio = yRatio;
        }

        protected function get view():Sprite {
            return _view;
        }

        protected function set view(value:Sprite):void {
            if (value != _view) {
                _view = value;
                sprite.x = xRatio * view.width;
                sprite.y = yRatio * view.height;

                playerRadius = Math.min(view.width * wRatio / model.arena.size.cols / 2, view.height * hRatio / model.arena.size.rows / 2);

                view.addChild(sprite);
                trace("fps sprite:  ("+sprite.x+","+sprite.y+")  "+sprite.width+"x"+sprite.height+" vs "+view.width+"x"+view.height);

            }
        }

        public function destroy():void {
            _destroyed = true;
            if (view != null) {
                view3d.scene.removeChildByName(getObjContainerName());
                view3d.scene.removeChildByName(getWallContainerName());
                view3d.scene = null;
                view3d = null;
                sprite.removeChild(view3d);
                view.removeChild(sprite);
            }
        }

        protected function getObjContainerName():String {
            return player.id + "objcontainer";
        }

        protected function getWallContainerName():String {
            return player.id + "wallcontainer";
        }

        protected function getTailName():String {
            return player.id + "tail";
        }

        public function clear():void {
            trace("fp view clear");
            if (view3d != null && view3d.parent != null) {
                view3d.scene.removeChildByName(getObjContainerName());
                view3d.scene.removeChildByName(getWallContainerName());
                view3d.parent.removeChild(view3d);
            }

            view3d = new View3D();
            view3d.scene = visualiser.scene;
            cont = new ObjectContainer3D({ name:getObjContainerName(), visible:true });
            walls = new ObjectContainer3D({ name:getWallContainerName(), visible:true });

            head = new Sphere({ material:new WireColorMaterial(RemoteControlVisualiser.getColor(player.id)) });
            head.radius = playerRadius;
            cont.addChild(head);

            var wall:Cylinder = new Cylinder();
            wall.name = getTailName();
            wall.radius = playerRadius;
            wall.height = playerRadius * 2;
            wall.rotationX = 90;
            walls.addChild(wall);

            var plane:Plane = new Plane( {
                width:model.arena.size.cols * playerRadius * 2,
                height:model.arena.size.rows * playerRadius * 2,
                segmentsW:model.arena.size.cols / 8,
                segmentsH:model.arena.size.rows / 8
            });
            plane.material = new WireColorMaterial(0x9AD7DB);
            plane.moveTo(model.arena.size.cols * playerRadius, -1 * playerRadius, model.arena.size.rows * playerRadius);
            cont.addChild(plane);

            view3d.scene.addChild(cont);
            view3d.scene.addChild(walls);

            view3d.camera.moveTo(0, 0, 0);
            view3d.camera.lookAt(plane.position);
            sprite.addChild(view3d);
        }

        public function crash(playerId:int):void {
            visualiser.doneCrashing(this);
        }

        public function draw(view:Sprite):void {
            this.view = view;

            var posX:Number = (model.arena.size.cols - player.position.x) * playerRadius * 2;
            var posY:Number = playerRadius * 4;
            var posZ:Number = player.position.y * playerRadius * 2;

            var cameraOffset:Number = 12 * playerRadius;

            head.position = toVector3D(player.position);
            switch (player.direction) {
                case ArenaDirection.UP:
                    view3d.camera.moveTo(posX, posY, posZ + cameraOffset);

                    break;
                case ArenaDirection.DOWN:
                    view3d.camera.moveTo(posX, posY, posZ - cameraOffset);

                    break;
                case ArenaDirection.LEFT:
                    view3d.camera.moveTo(posX - cameraOffset, posY, posZ);

                    break;
                case ArenaDirection.RIGHT:
                    view3d.camera.moveTo(posX + cameraOffset, posY, posZ);

                    break;
            }
            view3d.camera.lookAt(head.position);
            if (walls.children.length < player.moves.length) {
                // should draw last wall

                var start:PlayerMove = player.moves[player.moves.length - 2];
                var end:PlayerMove = player.moves[player.moves.length -1];
                drawPlayerWall(start.position, end.position);
            }
            var wall:Cylinder = walls.getChildByName(getTailName()) as Cylinder;
            var move:PlayerMove = player.moves[player.moves.length - 1] as PlayerMove;
            drawPlayerWall(move.position, player.position, wall);

            try {
            view3d.render();
            } catch (e:Error) {
                trace("there was an away3d render error for player "+player.id+".  "+e);
            }
        }

        public function drawEverything(view:Sprite):void {
            this.view = view;

            clear();
            draw(view);
        }

        protected function drawPlayerWall(start:ArenaPosition, end:ArenaPosition, wall:Cylinder = null):void {
            if (start == null || end == null) {
                return;
            }

            var color:uint = RemoteControlVisualiser.getColor(player.id);
            var dx:Number = end.x - start.x;
            var dy:Number = end.y - start.y;
            var length:Number = dx == 0 ? Math.abs(dy) : Math.abs(dx);
            if (wall == null) {
                wall = new Cylinder();
                wall.radius = playerRadius;
                wall.rotationX = 90;

                walls.addChild(wall);
            }

            wall.height = length * playerRadius * 2;

            if (dx == 0) {
                wall.rotationY = 0;
            }

            if (dy == 0) {
                wall.rotationY = 90;
            }

//            trace("move wall to:  "+[(2 * model.arena.size.cols - (start.x + end.x)) * playerRadius, 2 * playerRadius, (start.y + end.y) * playerRadius]);
            wall.moveTo((2 * model.arena.size.cols - (start.x + end.x)) * playerRadius, 2 * playerRadius, (start.y + end.y) * playerRadius);
        }

        protected function toVector3D(pos:ArenaPosition):Vector3D {
            return new Vector3D((model.arena.size.cols - pos.x) * playerRadius * 2,
                0,
                pos.y * playerRadius * 2);
        }
    }
}
