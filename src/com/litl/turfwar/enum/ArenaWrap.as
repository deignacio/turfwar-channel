package com.litl.turfwar.enum {
    public class ArenaWrap {
        public static const WRAP_YES:ArenaWrap = new ArenaWrap("wrap across walls", true);
        public static const WRAP_NO:ArenaWrap = new ArenaWrap("crash at walls", false);

        public static const ALL_WRAPS:Array = [ WRAP_YES, WRAP_NO ];

        public var name:String;
        public var shouldWrap:Boolean;

        public function ArenaWrap(name:String, shouldWrap:Boolean = false) {
            this.name = name;
            this.shouldWrap = shouldWrap;
        }

        public function toString():String {
            return name;
        }
    }
}
