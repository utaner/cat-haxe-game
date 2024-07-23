package en;

import entity.BaseEntity;
import entity.HSpriteEntity;


import h2d.Bitmap;
import format.agal.Data.C;
class Particle extends HSpriteEntity {


    public function new() {
        super(5, 5);


        circularRadius = 4;

        initLife(100);


        spr.anim.registerStateAnim(D.prc.run, 0);
        sprScaleX = 0.5;
        sprScaleY = 0.5;


    }

    public function getSpriteLib():SpriteLib {
        return Assets.particle;
    }


    override function onCircularCollision(e:BaseEntity) {
        super.onCircularCollision(e);
        if (e is Mob) {
            var m:Mob = cast e;
            m.hit(1, this);
        }

    }


    override function dispose() {
        super.dispose();
    }


    override function hit(dmg:Int, from:Null<BaseEntity>) {
        super.hit(dmg, from);


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

    /** X collisions **/
    override function onPreStepX() {
        super.onPreStepX();
        // Right collision

        if (xr > 0.8 && level.hasCollision(cx + 1, cy))
            xr = 0.8;

        if (xr < 0.2 && level.hasCollision(cx - 1, cy))
            xr = 0.2;
    }

    /** Y collisions **/
    override function onPreStepY() {
        super.onPreStepY();

        // Down collision
        if (yr > 0.8 && level.hasCollision(cx, cy + 1)) {
            yr = 0.8;
            vBase.dy = 0;
        }

        // Up collision
        if (yr < 0.2 && level.hasCollision(cx, cy - 1)) {
            yr = 0.2;
            vBase.dy = 0;
        }

        // depth sorting h2d.Layers
    }


    override function preUpdate() {
        super.preUpdate();


    }

    override function fixedUpdate() {
        super.fixedUpdate();
    }


}
