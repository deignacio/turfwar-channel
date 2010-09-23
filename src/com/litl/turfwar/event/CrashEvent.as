package com.litl.turfwar.event
{
    import com.litl.turfwar.Player;

    import flash.events.Event;

    public class CrashEvent extends Event
    {
        public static const CRASH:String = "crash";

        public var player:Player;
        public var causerId:int;

        public function CrashEvent(player:Player = null, causerId:int = 0)
        {
            super(CRASH);

            this.player = player;
            this.causerId = causerId;
        }

        override public function clone():Event {
            return new CrashEvent(player, causerId);
        }
    }
}
