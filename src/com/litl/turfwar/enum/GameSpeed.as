package com.litl.turfwar.enum {
    public class GameSpeed {
        public static const FAST:GameSpeed = new GameSpeed("fast", 25);
        public static const NORMAL:GameSpeed = new GameSpeed("normal", 50);
        public static const SLOW:GameSpeed = new GameSpeed("slow", 100);

        public static const ALL_SPEEDS:Array = [ FAST, NORMAL, SLOW ];

        public var name:String;
        public var speed:int;

        public function GameSpeed(name:String, speed:int) {
            this.name = name;
            this.speed = speed;
        }

        public function toString():String {
            return name;
        }
    }
}
