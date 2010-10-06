package com.litl.sdk.richinput.keypad {
    /**
     * Interface describing the required methods to be implemented
     * in order to be registered as a button in an AccelerometerKeypad.
     *
     * @see KeypadButtonBase
     */
    public interface IKeypadButton {
        /** a unique identifier for the button */
        function get name():String;

        /**
         * given the accelerometer values [accX, accY, accZ]
         * return if the keypad button is considered pressed
         */
        function isPressed(values:Array):Boolean;
    }
}
