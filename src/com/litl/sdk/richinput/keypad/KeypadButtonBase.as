package com.litl.sdk.richinput.keypad {
    /**
     * A common implementation of the IKeypadButton interface.
     * Uses an array of KeypadButtonInterval objects to define
     * if the button is pressed.
     *
     * @see AccelerometerKeypad
     * @see IKeypadButton
     * @see KeypadButtonInterval
     */
    public class KeypadButtonBase implements IKeypadButton {
        private var _name:String;
        private var _intervals:Array;

        /** constructor */
        public function KeypadButtonBase(name:String, intervals:Array) {
            _name = name;
            _intervals = [].concat(intervals);
        }

        /** @inheritDoc */
        public function get name():String {
            return _name;
        }

        /** @inheritDoc */
        public function isPressed(values:Array):Boolean {
            var func:Function = function(interval:KeypadButtonInterval, index:int, arr:Array):Boolean {
                return checkInterval(values, interval);
            };
            return _intervals.every(func, null);
        }

        private function checkInterval(values:Array, interval:KeypadButtonInterval):Boolean {
            var value:Number = values[interval.axis];
            return value >= interval.min && value <= interval.max;
        }
    }
}
