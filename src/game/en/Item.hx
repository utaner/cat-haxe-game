package en;

import entity.HSpriteBEEntity;
import entity.BaseEntity;
import entity.HSpriteEntity;

class Item extends HSpriteEntity {
    public static var ALL:FixedArray<Item> = new FixedArray(1000) ;


    public var rageCharges = 0 ;
    public var dropCharge = false ;
    public var rank = 0 ;
    public var rankRatio(get, never):Float;

    inline function get_rankRatio()
    return rank / 2;

    public function new(d:Entity_Exp, posX:Int, posY:Int) {
        super(posX, posY);

        circularRadius = 15;
        circularWeightBase = 0;
        ALL.push(this);

        spr.set(Assets.tiles);
        spr.useCustomTile(d.f_Tile_getTile());
        moveSpeed = 0.001;
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
        if (e is Player) {
            dir = dirTo(player);
            gotoPx(player.attachX, player.attachY);


        }
    }

    override function onTouchEntity(e:BaseEntity) {
        super.onTouchEntity(e);
        if (e is Player) {
            onDie();
            var _p:Player = cast e;
            _p.addExp(20);
        }

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
