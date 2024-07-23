package en.objects;


import entity.HSpriteBEEntity;
import entity.BaseEntity;
import entity.HSpriteEntity;

class CampFire extends HSpriteEntity {
    public static var ALL:FixedArray<CampFire> = new FixedArray(1000) ;


    public var rageCharges = 0 ;
    public var dropCharge = false ;
    public var rank = 0 ;
    public var rankRatio(get, never):Float;

    inline function get_rankRatio()
    return rank / 2;

    public function new(d:Entity_CampFire) {
        super(5, 5);
        setPosCase(d.cx, d.cy);

        circularRadius = 5;
        circularWeightBase = 999;
        ALL.push(this);
        spr.setTexture(h3d.mat.Texture.fromColor(0, 0));
        moveSpeed = 0;

        var tile1 = d.f_Tile_getTile();
        var tile2 = d.f_Tile2_getTile();
        var anim = new h2d.Anim([tile1, tile2], spr);
        anim.loop = true;
        anim.speed = 8;
        anim.setPosition(-7, -13);


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
