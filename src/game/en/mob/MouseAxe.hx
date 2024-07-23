package en.mob;
import entity.BaseEntity;
import entity.HSpriteEntity;
class MouseAxe extends Mob {
    public static var ALL:FixedArray<MouseAxe> = new FixedArray(1000) ;

    public function new(mobX:Int, mobY:Int) {
        super(mobX, mobY);


        ALL.push(this);

        initLife(3);
        circularRadius = 4;
        spr.anim.registerStateAnim(D.mouseaxe.walk, 0.1, 0.5);
        spr.anim.registerStateAnim(D.mouseaxe.attack, 0.2, 0.5, () -> isChargingAction(CA_Attack));

        //offset
        spr.setCenterRatio(0.5, 0.5);

        this.damage = 10;

    }

    public function getSpriteLib():SpriteLib {
        return Assets.mouseaxe;
    }

    override function hit(dmg:Int, from:Null<BaseEntity>) {
        S.mousehit01(0.3).pitchRandomly();

        super.hit(dmg, from);
        blink(Red);

    }
}
