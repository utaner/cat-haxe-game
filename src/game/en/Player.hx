package en;

import entity.BaseEntity;
import entity.HSpriteEntity;
import ui.Bar;

import h2d.Bitmap;
import format.agal.Data.C;
import ui.win.LevelUp;
import entity.HSpriteBEEntity;
class Player extends HSpriteEntity {
    var ca:ControllerAccess<GameAction>;
    var pressQueue:Map<GameAction, Float> = new Map() ;

    // This is TRUE if the player is not falling
    var onGround(get, never):Bool;
    public var activeSkills = [] ;

    var exp:Int = 0 ;
    var pLevel:Int = 1 ;

    inline function get_onGround()
    return !destroyed && vBase.dy == 0 && yr == 1 && level.hasCollision(cx, cy + 1);

    var fullBar:Bitmap;

    public var batarangSkills:Array<Particle> = [] ;
    var batarangSkillTimer:Float = 0 ;
    var batarangSkillDuration:Float = 0.5 ;
    var batarangSkillCooldown:Float = 1 ;
    var batarangSkillSpeed:Float = 0.04 ;
    var batarangSkillDamage:Int = 1 ;
    var batarangSkillRange:Int = 30 ;
    var healthBar:Bar;
    public var mainDamage:Int = 1 ;
    var manaBar:Bar;
    var mana:Int = 100 ;
    var manaTimer:Float = 0 ;

    public var darkLightningSkillActive:Bool = false ;
    public var darkLightningSkillCooldown:Float = 300 ;
    var darkLightningSkillTimer:Float = 0 ;
    public var darkLightningSkillDamage:Int = 5 ;

    public function new() {
        super(5, 5);

        // Start point using level entity "PlayerStart"
        var start = level.data.l_Entities.all_PlayerStart[0];
        if (start != null)
            setPosCase(start.cx, start.cy);

        // Misc inits

        circularRadius = 4;

        initLife(100);

        // Camera tracks this
        camera.trackEntity(this, true);
        camera.clampToLevelBounds = true;
        camera.zoomTo(1.5);

        // Init controller
        ca = App.ME.controller.createAccess();
        ca.lockCondition = Game.isGameControllerLocked;

        // anchoring

        spr.anim.registerStateAnim(D.chr.idle, 0);

        spr.anim.registerStateAnim(D.chr.walk, 0.1, () -> isMoving());
        // spr.anim.registerStateAnim(D.chr.attack, 0.2, () -> isChargingAction(CA_Attack));


        var healthBarCol:Col = "#e33327" ;
        healthBar = new Bar(25, 2, healthBarCol, spr);
        healthBar.set(100, 100);
        healthBar.x = -12;
        healthBar.y = -23;

        renderLife(getLifeValue(), 100);
        addExp(0);

        var manaBarCol:Col = "#2e86de" ;
        manaBar = new Bar(25, 1, manaBarCol, spr);
        manaBar.set(100, 100);
        manaBar.x = -12;
        manaBar.y = -20;


    }

    public function getSpriteLib():SpriteLib {
        return Assets.character;
    }

    public function addExp(value:Int) {
        exp += value;
        var oldLevel = pLevel;
        var maxExp = calcLevel();
        hud.setExp(exp, maxExp, pLevel);
        if (oldLevel != pLevel) {

            LevelUpManager.openLevelUp();
        }


    }

    public function addNewParticle() {
        var batarang = new Particle();
        batarang.setPosPixel(attachX, attachY);
        batarangSkills.push(batarang);
    }

    public function calcLevel() {
        var expNeeded = 100 * pLevel;
        if (exp >= expNeeded) {
            pLevel++;
            exp -= expNeeded;

        }
        return expNeeded;

    }


    public function renderLife(value:Int, max:Int) {
        healthBar.set(value, max);

    }

    public function manaRender(value:Int, max:Int) {
        mana = value;
        manaBar.set(value, max);
    }

    override function dispose() {
        super.dispose();
        ca.dispose(); // don't forget to dispose controller accesses
    }

    inline function unlockControls() {
        cd.unset("controlsLock");
    }

    inline function getLockRemainingS() {
        return cd.getS("controlsLock");
    }

    inline function lockControlS(t:Float) {
        cd.setS("controlsLock", t, false);
    }

    override function hit(dmg:Int, from:Null<BaseEntity>) {
        super.hit(dmg, from);
        //lockControlS(0.2);
        blink(Red);
        if (!isAlive()) {
            bumpAwayFrom(from, 0.1);
        } else {
            bumpAwayFrom(from, 0.1);
            // spr.anim.playOverlap(D.ent.kHit);
        }
        renderLife(getLifeValue(), 100);
        //spr.anim.play('angry');

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

    inline function isPressedOrQueued(a:GameAction, remove = true) {
        if (ca.isPressed(a) || pressQueue.exists(a) && ftime - pressQueue.get(a) <= 0.3) {
            if (remove)
                pressQueue.set(a, -1);
            return true;
        } else
            return false;
    }

    override function preUpdate() {
        super.preUpdate();

        // Player input

        var stickDist = ca.getAnalogDist4(MoveLeft, MoveRight, MoveUp, MoveDown);
        var stickAng = ca.getAnalogAngle4(MoveLeft, MoveRight, MoveUp, MoveDown);
        if (isPressedOrQueued(Atk)) {
            chargeAction(CA_Attack, 0.1, (onComplete) -> {
                var any = false;
                for (e in getVictims(2)) {
                    any = true;
                    e.dir = e.dirTo(this);
                    e.cancelAction();
                    e.bumpAwayFrom(this, 0.15);
                    e.setAffectS(Stun, 0.3);
                    e.cd.setS("pushOthers", 1);
                    e.hit(mainDamage, this);
                }
                spr.anim.play(D.chr.attack);
            });
        }

        // Move
        var s = 0.015;
        if (stickDist > 0) {
            vBase.dx += Math.cos(stickAng) * stickDist * s * tmod;
            vBase.dy += Math.sin(stickAng) * stickDist * s * tmod;
            dir = ca.isDown(MoveLeft) ? -1 : ca.isDown(MoveRight) ? 1 : dir;
            healthBar.scaleX = dir;
            healthBar.x = -12 * dir;
            manaBar.scaleX = dir;
            manaBar.x = -12 * dir;
        }


        if (isPressedOrQueued(Jump)) {
            if (mana < 20) {
                manaBar.blink(0.3, 0.1);
                return;
            }


            spr.anim.play(D.chr.jump);

            // baktığı yöne doğru 2x speed sıçra
            vBase.dy -= Math.sin(stickAng) * -0.5;
            vBase.dx += dir * 0.2;
            S.catjump01(0.3).pitchRandomly();
            manaRender(mana - 20, 100);


        }


        //batanrang skill karakterin etrafında 50px uzağında etrafında döner
        if (batarangSkills != null) {
            var i = 0;
            for (batarangSkill in batarangSkills) {
                // batarangSkill.setPosPixel((attachX + batarangSkillRange * Math.cos(ftime * batarangSkillSpeed)), (attachY + batarangSkillRange * Math.sin(ftime * batarangSkillSpeed)));
                //particlerin arasına boşlu koy
                batarangSkill.setPosPixel((attachX + batarangSkillRange * Math.cos(ftime * batarangSkillSpeed + (i * 1))), (attachY + batarangSkillRange * Math.sin(ftime * batarangSkillSpeed + (i * 1))));
                i++;
            }
            //healthbar direction fix

        }

        //mana regen
        if (mana < 100) {
            manaTimer += tmod;
            if (manaTimer > 5) {
                manaRender(mana + 1, 100);
                manaTimer = 0;
            }
        }

        //darklightning skill
        if (darkLightningSkillActive) {
            //yakınlardaki rastgele bir düşmanın üstüne ekle
            darkLightningSkillTimer += tmod;

            for (e in en.Mob.ALL) {
                if (distPx(e) < 50 && darkLightningSkillTimer > darkLightningSkillCooldown) {
                    var darkLightning = new ParticleTwo(darkLightningSkillDamage);
                    darkLightning.setPosPixel(e.attachX, e.attachY);

                    darkLightningSkillTimer = 0;


                }
            }
        }

    }

    override function fixedUpdate() {
        super.fixedUpdate();

        //random lick
        /*
        if (!isMoving() && !isChargingAction(CA_Attack) && Math.random() < 0.01)
            spr.anim.play(D.chr.lick);

         */


    }
}
