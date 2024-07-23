package entity;

import batch.HSpriteBatchEntity;
abstract class HSpriteBEEntity extends BaseEntity {
    public static var batchMap:Map<SpriteLib, HSpriteBatch> = new Map<SpriteLib, HSpriteBatch>() ;

    /** Main entity HSprite instance **/
    public var spr:HSpriteBE;

    public function new(x:Int, y:Int) {
        super(x, y);

        var spriteLib:SpriteLib = getSpriteLib();
        if (!batchMap.exists(spriteLib)) {
            batchMap.set(spriteLib, new HSpriteBatch(spriteLib.tile, Game.ME.scroller));
        }

        var batch = batchMap.get(spriteLib);
        spr = new HSpriteBatchEntity(this, batch, spriteLib, null);
        //batch.add(spr);

        spr.setCenterRatio(pivotX, pivotY);
    }

    public abstract function getSpriteLib():SpriteLib;

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
    }

    public function over():Void {
        // Nothing
    }

}
