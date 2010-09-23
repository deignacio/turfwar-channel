package com.litl.turfwar {
    import com.litl.sdk.event.AccelerometerEvent;
    import com.litl.sdk.richinput.Accelerometer;
    import com.litl.sdk.richinput.IRemoteControl;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import com.litl.turfwar.enum.ArenaDirection;

    public class Player extends EventDispatcher{
        public static var INVALID_PLAYER_ID:int = 0;
        public static var ACCELEROMETER_TURN_THRESHOLD:Number = 0.4;

        private var _id:int;
        private var _acc:Accelerometer = null;

        private var _pos:ArenaPosition = null;
        private var _dir:String = null;

        private var running:Boolean = false;

        public function Player(id:int) {
            _id = id;
        }

        public function destroy():void {
            pause();
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
            dispatchEvent(new Event("crashed"));
        }

        public function get id():int {
            return _id;
        }

        public function get position():ArenaPosition {
            return _pos;
        }

        public function set position(value:ArenaPosition):void {
            _pos = value;
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
                    break;
                default:
                    trace("invalid direction?  how'd that happen");
                    break;
            }
        }

        protected function onAccelerometer(e:AccelerometerEvent):void {
            switch (_dir) {
                case ArenaDirection.UP:
                case ArenaDirection.DOWN:
                    var x:Number = e.accelerationX;
                    if (x <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        _dir = ArenaDirection.LEFT;
                        trace("player turned:  "+this);
                    } else if (x >= ACCELEROMETER_TURN_THRESHOLD) {
                        _dir = ArenaDirection.RIGHT;
                        trace("player turned:  "+this);
                    }
                    break;
                case ArenaDirection.LEFT:
                case ArenaDirection.RIGHT:
                    var y:Number = e.accelerationY;
                    if (y <= -1 * ACCELEROMETER_TURN_THRESHOLD) {
                        _dir = ArenaDirection.UP;
                        trace("player turned:  "+this);
                    } else if (y >= ACCELEROMETER_TURN_THRESHOLD) {
                        _dir = ArenaDirection.DOWN;
                        trace("player turned:  "+this);
                    }
                    break;
                default:
                    _dir = ArenaDirection.UP;
                    trace("initial player direction "+_dir);
                    break;
            }
        }

        override public function toString():String {
            return "[Player id="+_id+" pos="+_pos+" dir="+_dir+"]";
        }
    }
}
