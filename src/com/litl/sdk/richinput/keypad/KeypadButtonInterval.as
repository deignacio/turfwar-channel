package com.litl.sdk.richinput.keypad {
    /**
     * Provides a menas for describing a rule to determine if a set of
     * accelerometer values is depressing a button.  Each KeypadButtonInterval
     * describes a min and max value for a specified axis of accelerometer values.
     *
     * @see AccelerometerKeypad
     * @see KeypadButtonBase
     */
    public class KeypadButtonInterval {
        /**
         * the axis of the accelerometer to examine.
         *
         * @see com.litl.sdk.enum.AccelerometerAxis
         */
        public var axis:int;

        /** the minimum acceptable value for acceptance */
        public var min:Number;

        /** the maximum acceptable value for acceptance */
        public var max:Number;

        /** constructor */
        public function KeypadButtonInterval(axis:int, min:Number, max:Number) {
            this.axis = axis;
            this.min = min;
            this.max = max;
        }
    }
}
