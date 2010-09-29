package com.litl.turfwar {
    import com.litl.sdk.event.AccelerometerEvent;
    import com.litl.sdk.richinput.Accelerometer;
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.turfwar.enum.ArenaDirection;
    import com.litl.turfwar.event.CrashEvent;

    import flash.events.EventDispatcher;

    public class Player extends EventDispatcher{
        public static var INVALID_PLAYER_ID:int = 0;
        public static var ACCELEROMETER_TURN_THRESHOLD:Number = 0.4;
        public static var turnType:String = "firstperson";  // "topdown" or "firstperson", too lazy to enum

        private var _id:int;
        private var _acc:Accelerometer = null;

        private var _pos:ArenaPosition = null;
        private var _dir:String = null;
        private var _canTurn:Boolean = true;
        private var _needsWrapMove:Boolean = false;

        private var running:Boolean = false;

        public var score:PlayerScore;
        public var moves:Array;

        public function Player(id:int) {
            _id = id;
            score = new PlayerScore(id);
            moves = new Array();
        }

        public function destroy():void {
            pause();
            moves = null;
            _acc = null;
        }

        public function associateRemote(remote:IRemoteControl):void {
            if (remote.hasAccelerometer) {
                _acc = remote.accelerometer;
                resume();
            }
        }

        public function resume():void {
            if (_acc != null && !running) {
                _acc.addEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
                running = true;
            }
        }

        public function pause():void {
            if (_acc != null && running) {
                _acc.removeEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
                running = false;
            }
        }

        public function crash():void {
            trace("crashed!");
            score.crashes++;
            moves = new Array();
            direction = direction;
            dispatchEvent(new CrashEvent(this));
        }

        public function get id():int {
            return _id;
        }

        public function get position():ArenaPosition {
            return _pos;
        }

        public function set position(value:ArenaPosition):void {
            _pos = value;
            if (turnType == "topdown") {
                _canTurn = true;
            }
            if (_needsWrapMove) {
                moves.push(new PlayerMove(position, direction));
                _needsWrapMove = false;
            }
        }

        public function get direction():String {
            return _dir;
        }

        public function set direction(value:String):void {
            switch (value) {
                case ArenaDirection.UP:
                case ArenaDirection.DOWN:
                case ArenaDirection.LEFT:
                case ArenaDirection.RIGHT:
                    _dir = value;
                    _canTurn = false;
                    moves.push(new PlayerMove(position, direction));
                    trace("player turned:  "+this);
                    break;
                default:
                    trace("invalid direction?  how'd that happen");
                    break;
            }
        }

        public function addWrapMove():void {
            moves.push(new PlayerMove(position, direction));
            _needsWrapMove = true;
        }

        protected function onAccelerometer(e:AccelerometerEvent):void {
            switch (turnType) {
                case "topdown":
                    doTopDownTurning(e);
                    break;
                case "firstperson":
                    doFirstPersonTurning(e);
                    break;
            }
        }

        protected function doFirstPersonTurning(e:AccelerometerEvent):void {
            if (!_canTurn) {
                if (Math.abs(e.accelerationX) <= ACCELEROMETER_TURN_THRESHOLD / 2) {
                    _canTurn = true;
                }
                return;
            }

            var x:Number = e.accelerationX;
            switch (direction) {
                case ArenaDirection.UP:
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.LEFT;
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.RIGHT;
                    }
                    break;
                case ArenaDirection.DOWN:
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.RIGHT;
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.LEFT;
                    }
                    break;
                case ArenaDirection.LEFT:
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.DOWN;
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.UP;
                    }
                    break;
                case ArenaDirection.RIGHT:
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.UP;
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.DOWN;
                    }
                    break;
                default:
                    direction = ArenaDirection.UP;
                    break;
            }
        }

        protected function doTopDownTurning(e:AccelerometerEvent):void {
            if (!_canTurn) {
                return;
            }

            switch (direction) {
                case ArenaDirection.DOWN:
                case ArenaDirection.UP:
                    var x:Number = e.accelerationX;
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.LEFT;
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.RIGHT;
                    }
                    break;
                case ArenaDirection.LEFT:
                case ArenaDirection.RIGHT:
                    var y:Number = e.accelerationY;
                    if (y <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.DOWN;
                    } else if (y >= ACCELEROMETER_TURN_THRESHOLD) {
                        direction = ArenaDirection.UP;
                    }
                    break;
                default:
                    direction = ArenaDirection.UP;
                    break;
            }
        }

        override public function toString():String {
            return "[Player id="+_id+" pos="+_pos+" dir="+_dir+"]";
        }
    }
}
