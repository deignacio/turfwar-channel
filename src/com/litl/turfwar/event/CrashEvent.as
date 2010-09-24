package com.litl.turfwar.event
{
    import com.litl.turfwar.Player;

    import flash.events.Event;

    public class CrashEvent extends Event
    {
        public static const CRASH:String = "crash";

        public var player:Player;

        public function CrashEvent(player:Player = null)
        {
            super(CRASH);

            this.player = player;
        }

        override public function clone():Event {
            return new CrashEvent(player);
        }
    }
}
