package en.mob;
import entity.BaseEntity;
import entity.HSpriteEntity;
class Mouse extends Mob {
    public static var ALL:FixedArray<Mouse> = new FixedArray(1000) ;

    public function new(mobX:Int, mobY:Int) {
        super(mobX, mobY);


        ALL.push(this);

        initLife(3);
        circularRadius = 4;
        lockAiS(1);

        spr.anim.registerStateAnim(D.mouse.walk, 0.1);
        spr.anim.registerStateAnim(D.mouse.attack, 0.2, () -> isChargingAction(CA_Attack));

        //offset
        spr.setCenterRatio(0.5, 0.6);
        this.damage = 5;
    }

    public function getSpriteLib():SpriteLib {
        return Assets.mouse;
    }

    override function hit(dmg:Int, from:Null<BaseEntity>) {
        S.mousehit01(0.3).pitchRandomly();

        super.hit(dmg, from);
        blink(Red);

    }
}
