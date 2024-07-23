package ui;

import ui.win.LevelUp;
class Hud extends GameChildProcess {
    var flow:h2d.Flow;
    var invalidated = true ;
    var notifications:Array<h2d.Flow> = [] ;
    var notifTw:dn.Tweenie;

    var debugText:h2d.Text;
    var levelBarCol:Col = "#94b0c2" ;
    var levelBar:Bar;
    var levelText:h2d.Text;
    var gameTimeText:h2d.Text;
    var mobCountText:h2d.Text;
    var mobKillCountText:h2d.Text;
    var mobKillCount:Int = 0 ;
    var bottomLeftFlow:h2d.Flow;
    var helperFlow:h2d.Flow;
    var skillSlotIconBar:ui.IconBar;
    var activeSkils:Array<String> = [] ;

    public function new() {
        super();

        notifTw = new Tweenie(Const.FPS);

        createRootInLayers(game.root, Const.DP_UI);
        root.filter = new h2d.filter.Nothing(); // force pixel perfect rendering

        flow = new h2d.Flow(root);
        flow.layout = Vertical;
        notifications = [];

        debugText = new h2d.Text(Assets.fontPixel, flow);
        debugText.filter = new dn.heaps.filter.PixelOutline();
        clearDebug();

        var topFlow = new h2d.Flow(flow);
        topFlow.layout = Horizontal;
        topFlow.horizontalAlign = Middle;
        topFlow.minWidth = 480;
        topFlow.y = 4;

        var centerFlow = new h2d.Flow(topFlow);
        centerFlow.layout = Vertical;
        centerFlow.verticalAlign = Middle;
        centerFlow.horizontalAlign = Middle;
        centerFlow.multiline = true;
        centerFlow.maxWidth = 200;


        levelBar = new Bar(200, 13, levelBarCol, centerFlow);
        levelText = new h2d.Text(Assets.fontPixel, levelBar);
        levelText.textColor = 0xffffff;
        levelText.text = "Level 1";
        levelText.filter = new dn.heaps.filter.PixelOutline();
        levelText.x = 4;
        levelText.y = -1;


        var bottomFlow = new h2d.Flow(centerFlow);
        bottomFlow.fillWidth = true;
        bottomFlow.horizontalAlign = Top;
        bottomFlow.verticalAlign = Top;


        var mobCountFlow = new h2d.Flow(bottomFlow);
        mobCountFlow.minWidth = 50;
        mobCountFlow.verticalAlign = Top;


        var mobCountIcon = new ui.IconBar(mobCountFlow);

        mobCountIcon.addIcons(D.tiles.deathicon);
        mobCountIcon.scale(1.3);

        mobCountText = new h2d.Text(Assets.fontPixel, mobCountFlow);
        mobCountText.textColor = 0xffffff;
        mobCountText.filter = new dn.heaps.filter.PixelOutline();
        mobCountText.text = "0";


        var centerFlow = new h2d.Flow(bottomFlow);
        centerFlow.verticalAlign = Middle;
        centerFlow.horizontalAlign = Middle;
        centerFlow.fillHeight = true;
        centerFlow.minWidth = 100;

        gameTimeText = new h2d.Text(Assets.fontPixel, centerFlow);
        gameTimeText.textColor = 0xffffff;
        gameTimeText.filter = new dn.heaps.filter.PixelOutline();
        gameTimeText.text = "00:00";

        var rightFlow = new h2d.Flow(bottomFlow);
        rightFlow.verticalAlign = Right;
        rightFlow.minWidth = 50;

        var mobKillCountIcon = new ui.IconBar(rightFlow);
        mobKillCountIcon.addIcons(D.tiles.deathicon2);
        mobKillCountIcon.scale(1.3);

        mobKillCountText = new h2d.Text(Assets.fontPixel, rightFlow);
        mobKillCountText.textColor = 0xffffff;
        mobKillCountText.filter = new dn.heaps.filter.PixelOutline();
        mobKillCountText.text = "0";

        bottomLeftFlow = new h2d.Flow(root);
        bottomLeftFlow.paddingBottom = 4;
        bottomLeftFlow.paddingLeft = 4;

        helperFlow = new h2d.Flow(root);
        helperFlow.paddingBottom = 4;
        helperFlow.paddingLeft = 4;
        //aşağı doğru
        helperFlow.layout = Vertical;

        var helpIcon = new ui.IconBar(helperFlow);
        helpIcon.addIcons(D.tiles.keyE);

        var helpText = new h2d.Text(Assets.fontPixel, helpIcon);
        //saldırı için e tuşunu kullan
        helpText.text = "Attack";
        helpText.textColor = 0xffffff;
        helpText.filter = new dn.heaps.filter.PixelOutline();
        helpText.x = 35;


        var helpIcon2 = new ui.IconBar(helperFlow);
        helpIcon2.addIcons(D.tiles.keySpace);

        var helpText2 = new h2d.Text(Assets.fontPixel, helpIcon2);
        //saldırı için e tuşunu kullan
        helpText2.text = "Jump";
        helpText2.textColor = 0xffffff;
        helpText2.filter = new dn.heaps.filter.PixelOutline();
        helpText2.x = 35;


        skillSlotIconBar = new ui.IconBar(bottomLeftFlow);
        skillSlotIconBar.overlapPx = -2;
        skillSlotIconBar.addIcons(D.tiles.emptySlot, 5);


    }

    override function onResize() {
        super.onResize();
        root.setScale(Const.UI_SCALE);
        flow.x = Std.int(0.5 * w() / Const.SCALE - flow.outerWidth * 0.5);
        flow.y = 1;
        bottomLeftFlow.x = 4;
        bottomLeftFlow.y = Std.int(h() / Const.UI_SCALE - bottomLeftFlow.outerHeight - 4);
        //helperFlow vertical center
        helperFlow.x = Std.int(w() / Const.UI_SCALE - helperFlow.outerWidth - 4);
        helperFlow.y = Std.int(h() / Const.UI_SCALE - helperFlow.outerHeight - 30);
    }

    public function addNewSkillSlot(skill:String) {

        skillSlotIconBar.empty();
        if (activeSkils.indexOf(skill) == -1) {
            activeSkils.push(skill);
        }
        for (s in activeSkils) {
            skillSlotIconBar.addIcons(s);
        }
        skillSlotIconBar.addIcons(D.tiles.emptySlot, 5 - activeSkils.length);

    }


    public function setTimeS(time:Float) {
        var min = Std.int(time / 60);
        var sec = Std.int(time % 60);
        gameTimeText.text = min + ":" + (sec < 10 ? "0" : "") + sec;
    }

    public function setExp(exp:Int, maxExp, level:Int) {
        levelBar.set(exp, maxExp);
        levelText.text = "Level " + level;
    }

    public function setMobCount(count:Int) {
        mobCountText.text = "" + count;
    }

    public function setMobKillCount(count:Int) {
        mobKillCount += count;
        mobKillCountText.text = "" + mobKillCount;
    }


    /** Clear debug printing **/
    public inline function clearDebug() {
        debugText.text = "";
        debugText.visible = false;
    }

    /** Display a debug string **/
    public inline function debug(v:Dynamic, clear = true) {
        if (clear)
            debugText.text = Std.string(v);
        else
            debugText.text += "\n" + v;
        debugText.visible = true;
        debugText.x = Std.int(w() / Const.UI_SCALE - 4 - debugText.textWidth);
    }

    /** Pop a quick s in the corner **/
    public function notify(str:String, color:Col = 0x0) {
        // Bg
        var t = Assets.tiles.getTile(D.tiles.uiNotification);
        var f = new dn.heaps.FlowBg(t, 5, root);
        f.colorizeBg(color);
        f.paddingHorizontal = 6;
        f.paddingBottom = 4;
        f.paddingTop = 0;
        f.paddingLeft = 9;
        f.y = 4;

        // Text
        var tf = new h2d.Text(Assets.fontPixel, f);
        tf.text = str;
        tf.maxWidth = 0.6 * w() / Const.UI_SCALE;
        tf.textColor = 0xffffff;
        tf.filter = new dn.heaps.filter.PixelOutline(color.toBlack(0.2));

        // Notification lifetime
        var durationS = 2 + str.length * 0.04;
        var p = createChildProcess();
        notifications.insert(0, f);
        p.tw.createS(f.x, -f.outerWidth > -2, TEaseOut, 0.1);
        p.onUpdateCb = () -> {
            if (p.stime >= durationS && !p.cd.hasSetS("done", Const.INFINITE))
                p.tw.createS(f.x, -f.outerWidth, 0.2).end(p.destroy);
        }
        p.onDisposeCb = () -> {
            notifications.remove(f);
            f.remove();
        }

        // Move existing notifications
        var y = 4;
        for (f in notifications) {
            notifTw.terminateWithoutCallbacks(f.y);
            notifTw.createS(f.y, y, TEaseOut, 0.2);
            y += f.outerHeight + 1;
        }
    }

    public inline function invalidate()
    invalidated = true;

    function render() {}

    public function onLevelStart() {}

    override function preUpdate() {
        super.preUpdate();
        notifTw.update(tmod);
    }

    override function postUpdate() {
        super.postUpdate();

        if (invalidated) {
            invalidated = false;
            render();
        }
    }
}
