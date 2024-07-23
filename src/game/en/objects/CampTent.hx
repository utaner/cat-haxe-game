package en.objects;


import entity.HSpriteBEEntity;
import entity.BaseEntity;
import entity.HSpriteEntity;

class CampTent extends HSpriteEntity {
    public static var ALL:FixedArray<CampTent> = new FixedArray(1000) ;


    public var rageCharges = 0 ;
    public var dropCharge = false ;
    public var rank = 0 ;
    public var rankRatio(get, never):Float;

    inline function get_rankRatio()
    return rank / 2;

    public function new(d:Entity_CampTent) {
        super(5, 5);
        setPosCase(d.cx, d.cy);

        circularRadius = 12;
        circularWeightBase = 9999;
        ALL.push(this);

        spr.set(Assets.tiles);
        spr.useCustomTile(d.f_Tile_getTile());
        moveSpeed = 0.001;

        spr.setCenterRatio(0.5, 0.6);
    }

    public function getSpriteLib():SpriteLib {
        return Assets.mouse;
    }


    override function dispose() {
        super.dispose();

        ALL.remove(this);
    }


    function aiLocked() {
        return !isAlive() || hasAffect(Stun) || isChargingAction() || cd.has("aiLock");
    }

    override function onTouchWall(wallX:Int, wallY:Int) {
        super.onTouchWall(wallX, wallY);
    }

    override function onCircularCollision(e:BaseEntity) {
        super.onCircularCollision(e);

    }

    override function onTouchEntity(e:BaseEntity) {
        super.onTouchEntity(e);


    }

    override function preUpdate() {
        super.preUpdate();
    }

    override function postUpdate() {
        super.postUpdate();
    }

    override function fixedUpdate() {
        super.fixedUpdate();

    }
}
