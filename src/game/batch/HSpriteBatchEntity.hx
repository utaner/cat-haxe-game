package batch;
import entity.HSpriteEntity;
import entity.BaseEntity;
class HSpriteBatchEntity extends HSpriteBE {
    public var entity:BaseEntity;

    public function new(entity:BaseEntity, sb:HSpriteBatch, l:SpriteLib, g:String, ?f = 0) {
        super(sb, l, g, f);
        this.entity = entity;
    }
}
