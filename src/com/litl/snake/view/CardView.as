package com.litl.snake.view {
    import com.litl.helpers.view.ViewBase;
    import com.litl.snake.skin.CardLogo;

    public class CardView extends ViewBase {
        private var logo:CardLogo;

        public function CardView() {
            super();
            logo = new CardLogo();
            logo.x = 0;
            logo.y = 0;
            logo.visible = true;
            addChild(logo);
        }
    }
}
