package com.litl.turfwar.enum {
    public class ArenaSize {
        public static const LARGE:ArenaSize = new ArenaSize("large", 133, 213);
        public static const MEDIUM:ArenaSize = new ArenaSize("medium", 90, 144);
        public static const SMALL:ArenaSize = new ArenaSize("small", 50, 80);

        public static const ALL_SIZES:Array = [ LARGE, MEDIUM, SMALL ];

        public var name:String;
        public var rows:int;
        public var cols:int;
        public var numSpots:int;

        public function ArenaSize(name:String, rows:int, cols:int) {
            this.name = name;
            this.rows = rows;
            this.cols = cols;
            this.numSpots = rows * cols;
        }

        public function toString():String {
            return name;
        }
    }
}
