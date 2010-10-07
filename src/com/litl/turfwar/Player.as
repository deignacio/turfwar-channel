package com.litl.turfwar {
    import com.litl.sdk.richinput.IRemoteControl;
    import com.litl.sdk.richinput.remotehandler.IRemoteHandler;
    import com.litl.sdk.richinput.keypad.AccelerometerKeypad;
    import com.litl.turfwar.enum.ArenaDirection;
    import com.litl.turfwar.event.CrashEvent;

    import flash.events.EventDispatcher;

    public class Player extends EventDispatcher implements IRemoteHandler {
        public static var INVALID_PLAYER_ID:int = 0;
        public static var ACCELEROMETER_TURN_THRESHOLD:Number = 0.4;

        private var _id:int;

        private var _pos:ArenaPosition = null;
        private var _dir:String = null;

        private var running:Boolean = false;

        public var score:PlayerScore;
        private var keypad:AccelerometerKeypad = null;

        public function Player(id:int) {
            _id = id;
            score = new PlayerScore(id);
        }

        public function pair(remote:IRemoteControl):void {
            if (remote.hasAccelerometer) {
                keypad = new ArenaDirectionKeypad(remote.accelerometer);
                resume();
            }
        }

        public function unpair(remote:IRemoteControl):void {
            pause();
            keypad.destroy();
            keypad = null;
        }

        public function resume():void {
            if (keypad != null && !running) {
                keypad.start();
                running = true;
            }
        }

        public function pause():void {
            if (keypad != null && running) {
                keypad.stop();
                running = false;
            }
        }

        public function crash(causerId:int):void {
            trace("crashed!  caused by " + causerId);
            score.crashes++;
            direction = direction;
            if (causerId == id) {
                causerId = 0;
            }
            dispatchEvent(new CrashEvent(this, causerId));
        }

        public function recordCrashCause():void {
            score.caused++;
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
                case ArenaDirection.NORTH:
                case ArenaDirection.SOUTH:
                case ArenaDirection.WEST:
                case ArenaDirection.EAST:
                    _dir = value;
                    trace("player turned:  "+this);
                    break;
                default:
                    trace("invalid direction?  how'd that happen");
                    break;
            }
        }

        public function maybeTurn():void {
            switch (direction) {
                case ArenaDirection.NORTH:
                case ArenaDirection.SOUTH:
                    if (keypad.isButtonPressed(ArenaDirection.EAST)) {
                        direction = ArenaDirection.EAST;
                    } else if (keypad.isButtonPressed(ArenaDirection.WEST)) {
                        direction = ArenaDirection.WEST;
                    }
                    break;
                case ArenaDirection.WEST:
                case ArenaDirection.EAST:
                    if (keypad.isButtonPressed(ArenaDirection.NORTH)) {
                        direction = ArenaDirection.NORTH;
                    } else if (keypad.isButtonPressed(ArenaDirection.SOUTH)) {
                        direction = ArenaDirection.SOUTH;
                    }
                    break;
                default:
                    direction = ArenaDirection.NORTH;
                    break;
            }
        }

        override public function toString():String {
            return "[Player id="+_id+" pos="+_pos+" dir="+_dir+"]";
        }
    }
}
