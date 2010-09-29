package com.litl.turfwar
{
    import com.litl.turfwar.enum.ArenaDirection;

    public class PlayerMove {
        public var position:ArenaPosition;
        public var direction:String;
        public function PlayerMove(pos:ArenaPosition, dir:String) {
            position = pos;
            direction = dir;
        }
    }
}
