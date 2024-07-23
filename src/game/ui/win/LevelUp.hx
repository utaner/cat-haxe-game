package ui.win;

typedef LevelUpItem = {
var f:h2d.Flow;
var tf:h2d.Text;
var close:Bool;
var cb:Void -> Void;
}
class LevelUp extends ui.Modal {
    var useMouse:Bool;
    var labelPadLen = 24 ;

    var curIdx(default, set) = 0 ;
    public var cur(get, never):Null<LevelUpItem>;

    inline function get_cur() return items.get(curIdx);

    var items:FixedArray<LevelUpItem> = new FixedArray(40) ;
    var cursor:h2d.Bitmap;
    var cursorInvalidated = true ;

    public function new(useMouse = true) {
        super(App.ME);

        this.useMouse = useMouse;
        win.padding = 1;
        win.enableInteractive = useMouse;
        win.verticalSpacing = 0;

        mask.enableInteractive = useMouse;
        if (useMouse) {
            mask.interactive.enableRightButton = true;
        }

        invalidateCursor();
        initMenu();
        ca.lock(0.1);
    }

    inline function set_curIdx(v) {
        if (curIdx != v)
            invalidateCursor();
        return curIdx = v;
    }


    function initMenu() {
        items.empty();
        win.removeChildren();
        cursor = new h2d.Bitmap(h2d.Tile.fromColor(Black), win);
        win.getProperties(cursor).isAbsolute = true;

        invalidateCursor();
    }

    public function addSpacer() {
        var f = new h2d.Flow(win);
        f.minWidth = f.minHeight = 4;
    }

    public function addTitle(str:String) {
        var f = new h2d.Flow(win);
        f.padding = 2;
        if (items.allocated > 0)
            f.paddingTop = 6;

        var tf = new h2d.Text(Assets.fontPixelMono, f);
        tf.textColor = Col.coldGray(0.6);
        tf.text = Lib.padRight(str.toUpperCase(), labelPadLen, "_");
    }

    public function addButton(label:String, cb:Void -> Void, desc:String = null, icon:String = null, close = true) {
        var f = new h2d.Flow(win);
        f.padding = 2;
        f.paddingBottom = 4;
        f.maxWidth = 300;
        //verticle flow
        f.multiline = true;
        f.verticalAlign = Middle;


        var leftFlow = new h2d.Flow(f);
        leftFlow.padding = 2;
        leftFlow.x = 0;
        leftFlow.fillHeight = true;
        leftFlow.verticalAlign = Left;

        var skillIcon = new ui.IconBar(leftFlow);
        skillIcon.scale(2);
        skillIcon.addIcons(icon, 1);

        var rightFlow = new h2d.Flow(f);
        rightFlow.padding = 2;
        rightFlow.x = 0;
        rightFlow.multiline = true;
        rightFlow.maxWidth = 250;
        rightFlow.verticalAlign = Top;
        rightFlow.horizontalAlign = Top;


        // Label
        var tf = new h2d.Text(Assets.fontPixelMono, rightFlow);
        tf.textColor = Black;
        tf.text = Lib.padRight(label, labelPadLen);


        // Description
        if (desc != null) {
            var tf2 = new h2d.Text(Assets.fontPixelMono, rightFlow);
            tf2.textColor = Col.coldGray(0.6);
            tf2.text = desc;
        }


        var i:LevelUpItem = { f:f, tf:tf, cb:cb, close:close }
        items.push(i);

        // Mouse controls
        if (useMouse) {
            f.enableInteractive = true;
            f.interactive.cursor = Button;
            f.interactive.onOver = _ -> moveCursorOn(i);
            f.interactive.onOut = _ -> if (cur == i) curIdx = -1;
            f.interactive.onClick = ev -> ev.button == 0 ? validate(i) : this.close();
            f.interactive.enableRightButton = true;
        }
    }

    function moveCursorOn(item:LevelUpItem) {
        var idx = 0;
        for (i in items) {
            if (i == item) {
                curIdx = idx;
                break;
            }
            idx++;
        }
    }

    function validate(item:LevelUpItem) {
        if (curIdx == -1) return;
        item.cb();
        if (item.close)
            close();
        else
            initMenu();
    }

    inline function invalidateCursor() {
        cursorInvalidated = true;
    }

    function updateCursor() {
        // Clean up
        for (i in items)
            i.f.filter = null;

        if (cur == null)
            cursor.visible = false;
        else {
            cursor.visible = true;
            cursor.width = win.innerWidth;
            cursor.height = cur.f.outerHeight;
            cursor.x = cur.f.x;
            cursor.y = cur.f.y;
            cur.f.filter = new dn.heaps.filter.Invert();
        }
    }

    override function postUpdate() {
        super.postUpdate();
        if (cursorInvalidated) {
            cursorInvalidated = false;
            updateCursor();
        }
    }

    override function update() {
        super.update();

        if (ca.isPressedAutoFire(MenuUp) && curIdx > 0)
            curIdx--;

        if (ca.isPressedAutoFire(MenuDown) && curIdx < items.allocated - 1)
            curIdx++;

        if (cur != null && ca.isPressed(MenuOk))
            validate(cur);
    }
}
