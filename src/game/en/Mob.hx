package en;

import entity.HSpriteBEEntity;
import entity.BaseEntity;
import entity.HSpriteEntity;

abstract class Mob extends HSpriteEntity {
    public static var ALL:FixedArray<Mob> = new FixedArray(1000) ;

    var weapon:Null<HSprite>;
    var weaponRot = 0. ;

    public var rageCharges = 0 ;
    public var dropCharge = false ;
    public var rank = 0 ;
    public var rankRatio(get, never):Float;
    public var damage = 1 ;

    inline function get_rankRatio()
    return rank / 2;

    public function new(mobX:Int, mobY:Int) {
        super(mobX, mobY);


        ALL.push(this);
    }


    public inline function lockAiS(t:Float) {
        cd.setS("aiLock", t, false);
    }


    override function onDie() {
        super.onDie();
        if (lastDmgSource != null) {
            dir = lastHitDirToSource;
            bumpAwayFrom(lastDmgSource, 0.3);
        }

        new Item(level.data.l_Entities.all_Exp[0], Math.round(cx), Math.round(cy));

        hud.setMobKillCount(1);

    }

    override function dispose() {
        super.dispose();

        ALL.remove(this);
    }

    public static inline function alives() {
        var n = 0;
        for (e in ALL)
            if (e.isAlive())
                n++;
        return n;
    }

    function aiLocked() {
        return !isAlive() || hasAffect(Stun) || isChargingAction() || cd.has("aiLock");
    }

    override function onTouchWall(wallX:Int, wallY:Int) {
        super.onTouchWall(wallX, wallY);
    }

    override function onTouchEntity(e:BaseEntity) {
        super.onTouchEntity(e);
        /*
			if (e.isAlive() && cd.has("pushOthers")) {
				if ((hasAffect(Stun) || !isAlive()) && !e.cd.has("mobBumpLock")) {
					setAffectS(Stun, 1);
					e.bumpAwayFrom(this, 0.3);
					e.setAffectS(Stun, 0.6);
					e.cd.setS("pushOthers", 0.5);
					e.cd.setS("mobBumpLock", 0.2);
					// if( dropCharge )
					// dropChargeItem();
				}
			}
		 */
    }

    override function preUpdate() {
        super.preUpdate();
    }

    override function postUpdate() {
        super.postUpdate();
    }

    override function fixedUpdate() {
        super.fixedUpdate();
        if (!aiLocked() && player.isAlive()) {

            // Follow player
            dir = dirTo(player);
            gotoPx(player.attachX, player.attachY);
            if (distPx(player) <= Const.GRID * 1.2) {
                chargeAction(CA_Attack, 0.3, (onComplete) -> {
                    lockAiS(0.5 - rankRatio * 0.3);
                    spr.anim.playOverlap(D.mouse.attack);
                    if (dirTo(player) == dir
                    && M.fabs(player.attachX - attachX) < Const.GRID * 1.2
                    && M.fabs(player.attachY - attachY) <= Const.GRID)
                        player.hit(this.damage, this);
                });
            }


        }
    }
}
