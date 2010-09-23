package com.litl.turfwar.view
{
    import com.litl.turfwar.skin.CardLogo;

    public class CardView extends ViewBase
    {
        public var logo:CardLogo;

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
