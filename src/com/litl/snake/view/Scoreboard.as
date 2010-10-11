package com.litl.snake.view
{
    import com.litl.control.VerticalList;
    import com.litl.snake.model.GameModel;
    import com.litl.snake.model.Player;
    import com.litl.snake.view.ScoreItemRenderer;

    public class Scoreboard extends PausedViewBase {
        private var model:GameModel;

        private var scoreList:VerticalList;
        private var scores:Array;

        public function Scoreboard(model:GameModel) {
            super();

            height = 500;
            width = 500;
            x = 25;
            y = 200;

            this.model = model;

            scoreList = new VerticalList();
            scoreList.itemRenderer = ScoreItemRenderer;
            scoreList.verticalScrollPolicy = "off";
            scoreList.itemSize = 50;
            scoreList.setSize(400, 350);
            scoreList.move(0, 0);
            addChild(scoreList);

            refresh();
        }

        override public function refresh():void {
            scores = new Array();
            model.forEachPlayer(getScore);
            scores.sort(scoreComparator);
            scoreList.dataProvider = scores;
        }

        private function getScore(player:Player):void {
            var score:Object = {
                "name": "Player " + player.id,
                "crashCount": player.crashCount,
                "causedCount": player.causedCount
            };

            scores.push(score);
        }

        private function scoreComparator(scoreA:Object, scoreB:Object):int {
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
