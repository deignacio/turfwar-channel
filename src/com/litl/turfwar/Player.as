package com.litl.turfwar {
    import com.litl.sdk.event.AccelerometerEvent;
    import com.litl.sdk.richinput.Accelerometer;
    import com.litl.sdk.richinput.IRemoteControl;

    public class Player {
        public static var INVALID_PLAYER_ID:int = 0;

        private var _id:int;
        private var _acc:Accelerometer = null;

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

        protected function onAccelerometer(e:AccelerometerEvent):void {
            // TODO:  implement this
        }
    }
}
