package com.litl.turfwar
{
    public class PlayerScore {

        public var name:String;
        public var color:uint;
        public var crashes:int;
        public var caused:int;

        public function PlayerScore(id:int,
                                    crashes:int = 0,
                                    caused:int = 0) {
            this.name = "Player " + id;
            this.color = color;
            this.crashes = crashes;
            this.caused = caused;
        }

        public function get score():String {
            return "crashed:" + crashes + " caused:" + caused;
        }

        public function toString():String {
            return name + " - " + score;
        }

        public static function compareFunction(scoreA:PlayerScore, scoreB:PlayerScore):int {
            var diffA:int = scoreA.caused - scoreA.crashes;
            var diffB:int = scoreB.caused - scoreB.crashes;
            if (diffA > diffB) {
                return -1;
            } else if (diffA == diffB) {
                if (scoreA.crashes > scoreB.crashes) {
                    return -1;
                } else if (scoreA.crashes == scoreB.crashes) {
                    return 0;
                } else {
                    return 1;
                }
            } else {
                return 1;
            }
        }
    }
}
