package com.litl.turfwar {
    import com.litl.turfwar.enum.ArenaDirection;
    import com.litl.turfwar.enum.ArenaSize;
    import com.litl.turfwar.view.PlayerShape;

    import flash.utils.Dictionary;

    public class ArenaModel {
        private var _size:ArenaSize = null;

        private var _spots:Dictionary;

        public function ArenaModel(size:ArenaSize) {
            this.size = size;
        }

        public function set size(value:ArenaSize):void {
            if (_size != value) {
                _size = value;
                reset();
            }
        }

        public function get size():ArenaSize {
            return _size;
        }

        protected function reset():void {
            _spots = new Dictionary();
        }

        public function enterArena(player:Player):void {
            var rand:int = Math.random() * size.numSpots;
           while (isSpotOccupied(rand)) {
                rand = Math.random() * size.numSpots;
           }
           player.position = getPosition(rand);
           trace("player entered arena at "+player.toString());
        }

        public function movePlayer(player:Player):void {
            if (player.position == null) {
                return;
            }

            var spot:int = getSpot(player.position);
            switch (player.direction) {
                case ArenaDirection.UP:
                    spot -= size.cols;
                    if (spot < 0) {
                        spot += size.numSpots + 1;
                    }
                    break;
                case ArenaDirection.DOWN:
                    spot += size.cols;
                    if (spot > size.numSpots) {
                        spot -= size.numSpots + 1;
                    }
                    break;
                case ArenaDirection.LEFT:
                    spot -= 1;
                    break;
                case ArenaDirection.RIGHT:
                    spot += 1;
                    break;
            }
            if (isSpotOccupied(spot)) {
                player.crash();
                reset();
            } else {
                player.position = getPosition(spot);
                claimPosition(player);
            }
        }

        public function getTrailShape(player:Player):PlayerShape {
            if (player.position == null) {
                return null;
            }

            var spot:int = getSpot(player.position);
            switch (player.direction) {
                case ArenaDirection.DOWN:
                    spot -= size.cols;
                    if (spot < 0) {
                        spot += size.numSpots + 1;
                    }
                    break;
                case ArenaDirection.UP:
                    spot += size.cols;
                    if (spot > size.numSpots) {
                        spot -= size.numSpots + 1;
                    }
                    break;
                case ArenaDirection.RIGHT:
                    spot -= 1;
                    break;
                case ArenaDirection.LEFT:
                    spot += 1;
                    break;
            }
            if (isSpotOccupied(spot)) {
                return _spots[String(spot)];
            } else {
                return null;
            }

        }

        private function getPosition(spot:int):ArenaPosition {
            return new ArenaPosition(spot % size.cols, spot / size.cols);
        }

        private function isSpotOccupied(spot:int):Boolean {
            return _spots.hasOwnProperty(String(spot));
        }

        private function claimPosition(player:Player):void {
            _spots[String(getSpot(player.position))] = new PlayerShape(player.id, player.position);
        }

        private function getSpot(pos:ArenaPosition):int {
            return pos.x + pos.y * size.cols;
        }

        public function leaveArena(player:Player):void {
            for (var spot:String in _spots) {
                unclaimSpot(player, spot);
            }
        }

        protected function unclaimSpot(player:Player, spot:String):Boolean {
            if (_spots[spot] == player) {
                delete _spots[spot];
                return true;
            }
            return false;
        }

        public function forEachSpot(func:Function):void {
            if (func != null) {
                var playerShape:PlayerShape;
                for (var spot:String in _spots) {
                    playerShape = _spots[spot];
                    func(playerShape);
                }
            }
        }
    }
}
