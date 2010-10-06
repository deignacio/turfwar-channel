package com.litl.sdk.richinput.keypad {
    import com.litl.sdk.event.AccelerometerEvent;
    import com.litl.sdk.richinput.Accelerometer;

    import flash.utils.Dictionary;

    /**
     * AccelerometerKeypad is intended to provide developers with a
     * simple, intuitive and yet robust way to use the accelerometer
     * values of a remote as a virtual keypad.
     *
     * This is accomplished by registering a named IKeypadButton instance
     * with the Keypad, and then at some interval, whether it be in
     * a game loop, on enter frame or timer tick, or in response to
     * some other event, checking to see which buttons are pressed and
     * taking the appropriate action.
     *
     * @see com.litl.sdk.richinput.keypad.IKeypadButton
     */
    public class AccelerometerKeypad {
        private var _acc:Accelerometer;
        private var _buttons:Dictionary;
        private var _accX:Number = 0;
        private var _accY:Number = 0;
        private var _accZ:Number = 0;

        private var _connected:Boolean = false;

        /** constructor. */
        public function AccelerometerKeypad(accel:Accelerometer) {
            _acc = accel;
            _buttons = new Dictionary();
        }

        /** Connect to the accelerometer and start processing events (idempotent) */
        public function start():void {
            if (!_connected) {
                _acc.addEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
            }
        }

        /** Disconnect from the accelerometer and stop processing events (idempotent)*/
        public function stop():void {
            if (_connected) {
                _acc.removeEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
            }
        }

        /**
         * adds the provided button to the keypad.
         *
         * note:  registered buttons are unique to button.name, a second
         *   button will overwrite/replace any buttons previously registered
         *   with the same name
         */
        public function registerButton(button:IKeypadButton):void {
            if (button != null) {
                _buttons[button.name] = button;
            }
        }

        /**
         * removes the provided button from the keypad.
         *
         * note:  no error is thrown if the button is not
         * in fact registered, this will just pass silently
         */
        public function unregisterButton(button:IKeypadButton):void {
            if (button != null) {
                delete _buttons[button.name];
            }
        }

        /**
         * determines if the current accelerometer values are
         * "pressing" a registered button of the provided name.
         *
         * note:  if the name does not exist, returns false.
         */
        public function isButtonPressed(name:String):Boolean {
            var button:IKeypadButton = _buttons[name];
            if (button != null) {
                return button.isPressed([_accX, _accY, _accZ]);
            }
            return false;
        }

        /**
         * determines if multiple buttons are pressed w/the
         * current accelerometer values.
         *
         * note:  if any of the names do not exist, returns false
         */
        public function areButtonsPressed(names:Array):Boolean {
            return names.every(isButtonPressed);
        }

        private function onAccelerometer(e:AccelerometerEvent):void {
            _accX = e.accelerationX;
            _accY = e.accelerationY;
            _accZ = e.accelerationZ;
        }

        /**
         * stops keypad and removes all buttons.
         *
         * note:  once destroyed not use the keypad.
         */
        public function destroy():void {
            stop();
            _acc = null;
            _buttons = null;
        }
    }
}
