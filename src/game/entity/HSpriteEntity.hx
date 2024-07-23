package entity;

abstract class HSpriteEntity extends BaseEntity {
    /** Main entity HSprite instance **/
    public var spr:HSprite;

    public function new(x:Int, y:Int) {
        super(x, y);

        spr = new HSprite();
        spr.setCenterRatio(pivotX, pivotY);
        spr.set(getSpriteLib());
        Game.ME.scroller.add(spr, Const.DP_MAIN);
        spr.colorAdd = new h3d.Vector();
    }

    /** Remove sprite from display context. Only do that if you're 100% sure your entity won't need the `spr` instance itself. **/
    public function noSprite() {
        //spr.setEmptyTexture();
        spr.remove();
    }

    public override function set_pivotX(v) {
        pivotX = super.set_pivotX(v);
        if (spr != null)
            spr.setCenterRatio(pivotX, pivotY);
        return pivotX;
    }

    public override function set_pivotY(v) {
        pivotY = super.set_pivotY(v);
        if (spr != null)
            spr.setCenterRatio(pivotX, pivotY);
        return pivotY;
    }

    public override function postUpdate() {
        spr.x = sprX;
        spr.y = sprY;
        spr.scaleX = dir * sprScaleX * sprSquashX;
        spr.scaleY = sprScaleY * sprSquashY;
        spr.visible = entityVisible;

        if (cd.has("shaking")) {
            spr.x += Math.cos(ftime * 1.1) * shakePowX * cd.getRatio("shaking");
            spr.y += Math.sin(0.3 + ftime * 1.7) * shakePowY * cd.getRatio("shaking");
        }

        super.postUpdate();

        spr.colorAdd.load(baseColor);
        spr.colorAdd.r += blinkColor.r;
        spr.colorAdd.g += blinkColor.g;
        spr.colorAdd.b += blinkColor.b;
    }

    public function over():Void {
        game.scroller.over(spr);
    }

    public override function blink(c:Col):Void {
        blinkColor.setColor(c);
        cd.setS("keepBlink", 0.06);
    }

    public override function onDie():Void {
        super.onDie();
        spr.remove();
    }
}
