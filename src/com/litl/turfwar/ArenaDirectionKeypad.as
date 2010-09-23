package com.litl.turfwar {
    import com.litl.sdk.enum.AccelerometerAxis;
    import com.litl.sdk.richinput.Accelerometer;
    import com.litl.sdk.richinput.keypad.AccelerometerKeypad;
    import com.litl.sdk.richinput.keypad.KeypadButtonBase;
    import com.litl.sdk.richinput.keypad.KeypadButtonInterval;
    import com.litl.turfwar.enum.ArenaDirection;

    public class ArenaDirectionKeypad extends AccelerometerKeypad {
        public static const MIN_THRESHOLD:Number = 0.4;
        public static const MAX_THRESHOLD:Number = 3.0;

        public function ArenaDirectionKeypad(accel:Accelerometer) {
            super(accel);

            this.registerButton(new KeypadButtonBase(ArenaDirection.NORTH,
                [ new KeypadButtonInterval(AccelerometerAxis.Y,
                    MIN_THRESHOLD, MAX_THRESHOLD) ]));
            this.registerButton(new KeypadButtonBase(ArenaDirection.SOUTH,
                [ new KeypadButtonInterval(AccelerometerAxis.Y,
                -1 * MAX_THRESHOLD, -1 * MIN_THRESHOLD) ]));
            this.registerButton(new KeypadButtonBase(ArenaDirection.EAST,
                [ new KeypadButtonInterval(AccelerometerAxis.X,
                    MIN_THRESHOLD, MAX_THRESHOLD) ]));
            this.registerButton(new KeypadButtonBase(ArenaDirection.WEST,
                [ new KeypadButtonInterval(AccelerometerAxis.X,
                    -1 * MAX_THRESHOLD, -1 * MIN_THRESHOLD) ]));
        }
    }
}
