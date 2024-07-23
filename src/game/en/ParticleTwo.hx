package en;

import entity.BaseEntity;
import entity.HSpriteEntity;


import h2d.Bitmap;
import format.agal.Data.C;
class ParticleTwo extends HSpriteEntity {

    var damage:Int;

    public function new(damage) {
        super(5, 5);
        this.damage = damage;

        circularRadius = 4;
        circularWeightBase = 999;

        initLife(100);


        spr.anim.registerStateAnim(D.prc2.run, 0);
        sprScaleX = 0.5;
        sprScaleY = 0.5;


    }

    public function getSpriteLib():SpriteLib {
        return Assets.particle2;
    }

    function hitMob(m:Mob) {
        m.hit(this.damage, this);
    }


    override function onCircularCollision(e:BaseEntity) {
        super.onCircularCollision(e);
        chargeAction(CA_Attack, 0.1, (onComplete) -> {
            if (e is Mob) {
                hitMob(cast e);
            }
            spr.anim.play(D.prc2.hit);
            spr.anim.onEnd(() -> {
                onDie();
            });


        });


    }


    override function dispose() {
        super.dispose();
    }


    inline function inHitRange(e:BaseEntity, rangeMul:Float) {
        return e.isAlive() && distPx(e) <= 10 * rangeMul && M.fabs(attachY - e.attachY) <= 6 + 6 * rangeMul && dirTo(e) == dir;
    }

    var _atkVictims:FixedArray<Mob> = new FixedArray(20) ; // alloc cache

    function getVictims(rangeMul:Float) {
        _atkVictims.empty();
        for (e in en.Mob.ALL)
            if (inHitRange(e, rangeMul))
                _atkVictims.push(e);
        return _atkVictims;
    }


    override function preUpdate() {
        super.preUpdate();


    }

    override function fixedUpdate() {
        super.fixedUpdate();
    }


}
