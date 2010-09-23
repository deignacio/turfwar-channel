package com.litl.turfwar.event {
    import flash.events.Event;

    public class NoPlayersEvent extends Event {
        public static const NO_PLAYERS:String = "no-players";

        public function NoPlayersEvent() {
            super(NO_PLAYERS);
        }

        override public function clone():Event {
            return new NoPlayersEvent();
        }
    }
}
