package entity;
abstract class BaseEntity {
    public static var ALL:FixedArray<BaseEntity> = new FixedArray(5000) ;
    public static var GC:FixedArray<BaseEntity> = new FixedArray(ALL.maxSize) ;

    var circularRadius:Float = 4 ;

    // Various getters to access all important stuff easily
    public var app(get, never):App;

    inline function get_app()
    return App.ME;

    final brakeDist = 16 ;

    public var game(get, never):Game;

    inline function get_game()
    return Game.ME;

    public var fx(get, never):Fx;

    inline function get_fx()
    return Game.ME.fx;

    public var level(get, never):Level;

    inline function get_level()
    return Game.ME.level;

    public var destroyed(default, null) = false ;
    public var ftime(get, never):Float;

    inline function get_ftime()
    return game.ftime;

    public var camera(get, never):Camera;

    inline function get_camera()
    return game.camera;

    var tmod(get, never):Float;

    inline function get_tmod()
    return Game.ME.tmod;

    var utmod(get, never):Float;

    inline function get_utmod()
    return Game.ME.utmod;

    public var hud(get, never):ui.Hud;

    inline function get_hud()
    return Game.ME.hud;

    public var player(get, never):Player;

    inline function get_player()
    return game.player;

    /** Cooldowns **/
    public var cd:dn.Cooldown;

    /** Cooldowns, unaffected by slowmo (ie. always in realtime) **/
    public var ucd:dn.Cooldown;

    /** Temporary gameplay affects **/
    var affects:Map<Affect, Float> = new Map() ;

    /** State machine. Value should only be changed using `startState(v)` **/
    public var state(default, null):State;

    /** Unique identifier **/
    public var uid(default, null):Int;

    /** Grid X coordinate **/
    public var cx:Int = 0 ;

    /** Grid Y coordinate **/
    public var cy:Int = 0 ;

    /** Sub-grid X coordinate (from 0.0 to 1.0) **/
    public var xr:Float = 0.5 ;

    /** Sub-grid Y coordinate (from 0.0 to 1.0) **/
    public var yr:Float = 1.0 ;

    var allVelocities:VelocityArray;

    /** Base X/Y velocity of the BaseEntity.Entity **/
    public var vBase:Velocity;

    /** "External bump" velocity. It is used to push the BaseEntity.Entity in some direction, independently of the "user-controlled" base velocity. **/
    public var vBump:Velocity;

    /** Last known X position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
    var lastFixedUpdateX = 0. ;

    /** Last known Y position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
    var lastFixedUpdateY = 0. ;

    /** If TRUE, the sprite display coordinates will be an interpolation between the last known position and the current one. This is useful if the gameplay happens in the `fixedUpdate()` (so at 30 FPS), but you still want the sprite position to move smoothly at 60 FPS or more. **/
    var interpolateSprPos = true ;

    var circularWeightBase:Float = 1 ;

    /** Total of all X velocities **/
    public var dxTotal(get, never):Float;

    inline function get_dxTotal()
    return allVelocities.getSumX();

    /** Total of all Y velocities **/
    public var dyTotal(get, never):Float;

    inline function get_dyTotal()
    return allVelocities.getSumY();

    /** Pixel width of entity **/
    public var wid(default, set):Float = Const.GRID ;

    inline function set_wid(v) {
        invalidateDebugBounds = true;
        return wid = v;
    }

    public var iwid(get, set):Int;

    inline function get_iwid()
    return M.round(wid);

    inline function set_iwid(v:Int) {
        invalidateDebugBounds = true;
        wid = v;
        return iwid;
    }

    /** Pixel height of entity **/
    public var hei(default, set):Float = Const.GRID ;

    inline function set_hei(v) {
        invalidateDebugBounds = true;
        return hei = v;
    }

    public var moveTarget:LPoint;

    public function gotoPx(x, y) {
        moveTarget.setLevelPixel(x, y);
    }

    public function gotoCase(x, y) {
        moveTarget.setLevelCase(x, y, 0.5, 0.5);
    }

    public inline function cancelMove() {
        moveTarget.setBoth(-1);
    }

    public var ihei(get, set):Int;

    inline function get_ihei()
    return M.round(hei);

    inline function set_ihei(v:Int) {
        invalidateDebugBounds = true;
        hei = v;
        return ihei;
    }

    /** Inner radius in pixels (ie. smallest value between width/height, then divided by 2) **/
    public var innerRadius(get, never):Float;

    private inline function get_innerRadius() {
        return M.fmin(wid, hei) * 0.5;
    }

    /** "Large" radius in pixels (ie. biggest value between width/height, then divided by 2) **/
    public var largeRadius(get, never):Float;

    private inline function get_largeRadius() {
        return M.fmax(wid, hei) * 0.5;
    }

    /** Horizontal direction, can only be -1 or 1 **/
    public var dir(default, set) = 1 ;

    /** Current sprite X **/
    public var sprX(get, never):Float;

    private inline function get_sprX() {
        return interpolateSprPos ? M.lerp(lastFixedUpdateX, (cx + xr) * Const.GRID, game.getFixedUpdateAccuRatio()) : (cx + xr) * Const.GRID;
    }

    /** Current sprite Y **/
    public var sprY(get, never):Float;

    private inline function get_sprY() {
        return interpolateSprPos ? M.lerp(lastFixedUpdateY, (cy + yr) * Const.GRID, game.getFixedUpdateAccuRatio()) : (cy + yr) * Const.GRID;
    }

    /** Sprite X scaling **/
    public var sprScaleX = 1.0 ;

    /** Sprite Y scaling **/
    public var sprScaleY = 1.0 ;

    /** Sprite X squash & stretch scaling, which automatically comes back to 1 after a few frames **/
    private var sprSquashX = 1.0 ;

    /** Sprite Y squash & stretch scaling, which automatically comes back to 1 after a few frames **/
    private var sprSquashY = 1.0 ;

    /** BaseEntity.Entity visibility **/
    public var entityVisible = true ;

    /** Current hit points **/
    public var life(default, null):dn.struct.Stat<Int>;

    public function getLifeValue() {
        return life.v;
    }

    public function getLifeMax() {
        return life.max;
    }

    /** Last source of damage if it was an BaseEntity.Entity **/
    public var lastDmgSource(default, null):Null<BaseEntity>;

    /** Horizontal direction (left=-1 or right=1): from "last source of damage" to "this" **/
    public var lastHitDirFromSource(get, never):Int;

    inline function get_lastHitDirFromSource()
    return lastDmgSource == null ? -dir : -dirTo(lastDmgSource);

    /** Horizontal direction (left=-1 or right=1): from "this" to "last source of damage" **/
    public var lastHitDirToSource(get, never):Int;

    inline function get_lastHitDirToSource()
    return lastDmgSource == null ? dir : dirTo(lastDmgSource);

    /** Color vector transformation applied to sprite **/
    public var baseColor:h3d.Vector;

    /** Color matrix transformation applied to sprite **/
    public var colorMatrix:h3d.Matrix;

    // Animated blink color on damage hit
    public var blinkColor:h3d.Vector;

    /** Sprite X shake power **/
    private var shakePowX = 0. ;

    /** Sprite Y shake power **/
    private var shakePowY = 0. ;

    // Debug stuff
    private var debugLabel:Null<h2d.Text>;
    private var debugBounds:Null<h2d.Graphics>;
    private var invalidateDebugBounds = false ;

    /** Defines X alignment of entity at its attach point (0 to 1.0) **/
    public var pivotX(default, set):Float = 0.5 ;

    public function set_pivotX(v) {
        return pivotX = M.fclamp(v, 0, 1);
    }

    /** Defines Y alignment of entity at its attach point (0 to 1.0) **/
    public var pivotY(default, set):Float = 1 ;

    public function set_pivotY(v) {
        return pivotY = M.fclamp(v, 0, 1);
    }

    /** BaseEntity.Entity attach X pixel coordinate **/
    public var attachX(get, never):Float;

    inline function get_attachX()
    return (cx + xr) * Const.GRID;

    /** BaseEntity.Entity attach Y pixel coordinate **/
    public var attachY(get, never):Float;

    inline function get_attachY()
    return (cy + yr) * Const.GRID;

    // Various coordinates getters, for easier gameplay coding

    /** Left pixel coordinate of the bounding box **/
    public var left(get, never):Float;

    inline function get_left()
    return attachX + (0 - pivotX) * wid;

    /** Right pixel coordinate of the bounding box **/
    public var right(get, never):Float;

    inline function get_right()
    return attachX + (1 - pivotX) * wid;

    /** Top pixel coordinate of the bounding box **/
    public var top(get, never):Float;

    inline function get_top()
    return attachY + (0 - pivotY) * hei;

    /** Bottom pixel coordinate of the bounding box **/
    public var bottom(get, never):Float;

    inline function get_bottom()
    return attachY + (1 - pivotY) * hei;

    /** Center X pixel coordinate of the bounding box **/
    public var centerX(get, never):Float;

    inline function get_centerX()
    return attachX + (0.5 - pivotX) * wid;

    /** Center Y pixel coordinate of the bounding box **/
    public var centerY(get, never):Float;

    inline function get_centerY()
    return attachY + (0.5 - pivotY) * hei;

    /** Current X position on screen (ie. absolute)**/
    public var screenAttachX(get, never):Float;

    inline function get_screenAttachX()
    return game != null && !game.destroyed ? sprX * Const.SCALE + game.scroller.x : sprX * Const.SCALE;

    /** Current Y position on screen (ie. absolute)**/
    public var screenAttachY(get, never):Float;

    inline function get_screenAttachY()
    return game != null && !game.destroyed ? sprY * Const.SCALE + game.scroller.y : sprY * Const.SCALE;

    /** attachX value during last frame **/
    public var prevFrameAttachX(default, null):Float = -Const.INFINITE ;

    /** attachY value during last frame **/
    public var prevFrameAttachY(default, null):Float = -Const.INFINITE ;

    var actions:RecyclablePool<tools.ChargedAction>;

    public function new(x:Int, y:Int) {
        uid = Const.makeUniqueId();
        ALL.push(this);

        cd = new dn.Cooldown(Const.FPS);
        ucd = new dn.Cooldown(Const.FPS);
        life = new Stat();
        setPosCase(x, y);
        initLife(1);
        state = Normal;
        actions = new RecyclablePool(15, () -> new tools.ChargedAction());

        allVelocities = new VelocityArray(15);
        vBase = registerNewVelocity(0.82);
        vBump = registerNewVelocity(0.93);

        moveTarget = new LPoint();
        moveTarget.setBoth(-1);
        //Game.ME.scroller.add(cast spr, Const.DP_MAIN);

        //spr.colorAdd = new h3d.Vector();
        baseColor = new h3d.Vector();
        blinkColor = new h3d.Vector();

        if (ui.Console.ME.hasFlag(F_Bounds))
            enableDebugBounds();
    }

    public abstract function getSpriteLib():SpriteLib;

    public function registerNewVelocity(frict:Float):Velocity {
        var v = Velocity.createFrict(frict);
        allVelocities.push(v);
        return v;
    }

    /** Initialize current and max hit points **/
    public function initLife(v) {
        life.initMaxOnMax(v);
    }

    /** Inflict damage **/
    public function hit(dmg:Int, from:Null<BaseEntity>) {
        if (!isAlive() || dmg <= 0)
            return;

        life.v -= dmg;
        lastDmgSource = from;
        onDamage(dmg, from);
        if (life.v <= 0)
            onDie();
    }

    /** Kill instantly **/
    public function kill(by:Null<BaseEntity>) {
        if (isAlive())
            hit(life.v, by);
    }

    function onDamage(dmg:Int, from:BaseEntity) {}

    function onDie() {
        destroy();
    }

    inline function set_dir(v) {
        return dir = v > 0 ? 1 : v < 0 ? -1 : dir;
    }

    /** Return TRUE if current entity wasn't destroyed or killed **/
    public inline function isAlive() {
        return !destroyed && life.v > 0;
    }

    /** Move entity to grid coordinates **/
    public function setPosCase(x:Int, y:Int) {
        cx = x;
        cy = y;
        xr = 0.5;
        yr = 1;
        onPosManuallyChangedBoth();
    }

    /** Move entity to pixel coordinates **/
    public function setPosPixel(x:Float, y:Float) {
        cx = Std.int(x / Const.GRID);
        cy = Std.int(y / Const.GRID);
        xr = (x - cx * Const.GRID) / Const.GRID;
        yr = (y - cy * Const.GRID) / Const.GRID;
        onPosManuallyChangedBoth();
    }

    /** Should be called when you manually (ie. ignoring physics) modify both X & Y entity coordinates **/
    function onPosManuallyChangedBoth() {
        if (M.dist(attachX, attachY, prevFrameAttachX, prevFrameAttachY) > Const.GRID * 2) {
            prevFrameAttachX = attachX;
            prevFrameAttachY = attachY;
        }
        updateLastFixedUpdatePos();
    }

    /** Should be called when you manually (ie. ignoring physics) modify entity X coordinate **/
    function onPosManuallyChangedX() {
        if (M.fabs(attachX - prevFrameAttachX) > Const.GRID * 2)
            prevFrameAttachX = attachX;
        lastFixedUpdateX = attachX;
    }

    /** Should be called when you manually (ie. ignoring physics) modify entity Y coordinate **/
    function onPosManuallyChangedY() {
        if (M.fabs(attachY - prevFrameAttachY) > Const.GRID * 2)
            prevFrameAttachY = attachY;
        lastFixedUpdateY = attachY;
    }

    /** Quickly set X/Y pivots. If Y is omitted, it will be equal to X. **/
    public function setPivots(x:Float, ?y:Float) {
        pivotX = x;
        pivotY = y != null ? y : x;
    }

    /** Return TRUE if the BaseEntity.Entity *center point* is in screen bounds (default padding is +32px) **/
    public inline function isOnScreenCenter(padding = 32) {
        return camera.isOnScreen(centerX, centerY, padding + M.fmax(wid * 0.5, hei * 0.5));
    }

    /** Return TRUE if the BaseEntity.Entity rectangle is in screen bounds (default padding is +32px) **/
    public inline function isOnScreenBounds(padding = 32) {
        return camera.isOnScreenRect(left, top, wid, hei, padding);
    }

    /**
		Changed the current entity state.
		Return TRUE if the state is `s` after the call.
	**/
    public function startState(s:State):Bool {
        if (s == state)
            return true;

        if (!canChangeStateTo(state, s))
            return false;


        var old = state;
        state = s;
        onStateChange(old, state);
        return true;
    }

    /** Return TRUE to allow a change of the state value **/
    function canChangeStateTo(from:State, to:State) {
        return true;
    }

    /** Called when state is changed to a new value **/
    function onStateChange(old:State, newState:State) {}

    /** Apply a bump/kick force to entity **/
    public function bump(x:Float, y:Float) {
        vBump.addXY(x, y);
    }

    /** Reset velocities to zero **/
    public function cancelVelocities() {
        allVelocities.clearAll();
    }

    public function is<T:BaseEntity>(c:Class<T>)
    return Std.isOfType(this, c);

    public function as<T:BaseEntity>(c:Class<T>):T
    return Std.downcast(this, c);

    /** Return a random Float value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
    public inline function rnd(min, max, ?sign)
    return Lib.rnd(min, max, sign);

    /** Return a random Integer value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
    public inline function irnd(min, max, ?sign)
    return Lib.irnd(min, max, sign);

    /** Truncate a float value using given `precision` **/
    public inline function pretty(value:Float, ?precision = 1)
    return M.pretty(value, precision);

    public inline function dirTo(e:BaseEntity)
    return e.centerX < centerX ? -1 : 1;

    public inline function dirToAng()
    return dir == 1 ? 0. : M.PI;

    public inline function getMoveAng()
    return Math.atan2(dyTotal, dxTotal);

    /** Return a distance (in grid cells) from this to something **/
    public inline function distCase(?e:BaseEntity, ?tcx:Int, ?tcy:Int, txr = 0.5, tyr = 0.5) {
        if (e != null)
            return M.dist(cx + xr, cy + yr, e.cx + e.xr, e.cy + e.yr);
        else
            return M.dist(cx + xr, cy + yr, tcx + txr, tcy + tyr);
    }

    /** Return a distance (in pixels) from this to something **/
    public inline function distPx(?e:BaseEntity, ?x:Float, ?y:Float) {
        if (e != null)
            return M.dist(attachX, attachY, e.attachX, e.attachY);
        else
            return return M.dist(attachX, attachY, x, y);
    }

    function canSeeThrough(cx:Int, cy:Int) {
        return !level.hasCollision(cx, cy) || this.cx == cx && this.cy == cy;
    }

    /** Check if the grid-based line between this and given target isn't blocked by some obstacle **/
    public inline function sightCheck(?e:BaseEntity, ?tcx:Int, ?tcy:Int) {
        if (e != null)
            return e == this ? true : dn.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
        else
            return dn.Bresenham.checkThinLine(cx, cy, tcx, tcy, canSeeThrough);
    }

    /** Create a LPoint instance from current coordinates **/
    public inline function createPoint()
    return LPoint.fromCase(cx + xr, cy + yr);

    /** Create a LRect instance from current entity bounds **/
    public inline function createRect()
    return tools.LRect.fromPixels(Std.int(left), Std.int(top), Std.int(wid), Std.int(hei));

    public final function destroy() {
        if (!destroyed) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

        allVelocities.dispose();
        allVelocities = null;
        baseColor = null;
        blinkColor = null;
        colorMatrix = null;
        moveTarget = null;

        //spr.remove();
        //spr = null;

        if (debugLabel != null) {
            debugLabel.remove();
            debugLabel = null;
        }

        if (debugBounds != null) {
            debugBounds.remove();
            debugBounds = null;
        }

        cd.dispose();
        cd = null;

        ucd.dispose();
        ucd = null;
    }

    /** Print some numeric value below entity **/
    public inline function debugFloat(v:Float, c:Col = 0xffffff) {
        debug(pretty(v), c);
    }

    function canMoveToTarget() {
        return isAlive() && moveTarget.cx >= 0;
    }

    inline function hasMoveTarget() {
        return moveTarget.cx >= 0;
    }

    /** Print some value below entity **/
    public inline function debug(?v:Dynamic, c:Col = 0xffffff) {
        #if debug
		if (v == null && debugLabel != null) {
			debugLabel.remove();
			debugLabel = null;
		}
		if (v != null) {
			if (debugLabel == null) {
				debugLabel = new h2d.Text(Assets.fontPixel, Game.ME.scroller);
				debugLabel.filter = new dn.heaps.filter.PixelOutline();
			}
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
    }

    public function bumpAwayFrom(e:BaseEntity, velocity:Float) {
        var a = Math.atan2(attachY - e.attachY, attachX - e.attachX);
        vBump.x += Math.cos(a) * velocity;
        vBump.y += Math.sin(a) * velocity * 0.66; // 2.5D z distortion
    }

    /** Hide entity debug bounds **/
    public function disableDebugBounds() {
        if (debugBounds != null) {
            debugBounds.remove();
            debugBounds = null;
        }
    }

    public abstract function over():Void;

    /** Show entity debug bounds (position and width/height). Use the `/bounds` command in Console to enable them. **/
    public function enableDebugBounds() {
        if (debugBounds == null) {
            debugBounds = new h2d.Graphics();
            game.scroller.add(debugBounds, Const.DP_TOP);
        }
        invalidateDebugBounds = true;
    }

    function renderDebugBounds() {
        var c = Col.fromHsl((uid % 20) / 20, 1, 1);
        debugBounds.clear();

        // Bounds rect
        debugBounds.lineStyle(1, c, 0.5);
        debugBounds.drawRect(left - attachX, top - attachY, wid, hei);

        // Attach point
        debugBounds.lineStyle(0);
        debugBounds.beginFill(c, 0.8);
        debugBounds.drawRect(-1, -1, 3, 3);
        debugBounds.endFill();

        // Center
        debugBounds.lineStyle(1, c, 0.3);
        debugBounds.drawCircle(centerX - attachX, centerY - attachY, 3);

        debugBounds.lineStyle(1, c, 0.5);
        debugBounds.drawCircle(0, 0, circularRadius);
    }

    /** Wait for `sec` seconds, then runs provided callback. **/
    function chargeAction(id:ChargedActionId, sec:Float, onComplete:ChargedAction -> Void, ?onProgress:ChargedAction -> Void) {
        if (!isAlive())
            return;

        if (isChargingAction(id))
            cancelAction(id);

        var a = actions.alloc();
        a.id = id;
        a.onComplete = onComplete;
        a.durationS = sec;
        if (onProgress != null)
            a.onProgress = onProgress;
    }

    /** If id is null, return TRUE if any action is charging. If id is provided, return TRUE if this specific action is charging nokw. **/
    public function isChargingAction(?id:ChargedActionId) {
        if (!isAlive())
            return false;

        if (id == null)
            return actions.allocated > 0;

        for (a in actions)
            if (a.id == id)
                return true;

        return false;
    }

    public function cancelAction(?onlyId:ChargedActionId) {
        if (!isAlive())
            return;

        if (onlyId == null)
            actions.freeAll();
        else {
            var i = 0;
            while (i < actions.allocated) {
                if (actions.get(i).id == onlyId)
                    actions.freeIndex(i);
                else
                    i++;
            }
        }
    }

    /** Action management loop **/
    function updateActions() {
        if (!isAlive())
            return;

        var i = 0;
        while (i < actions.allocated) {
            if (actions.get(i).update(tmod))
                actions.freeIndex(i);
            else
                i++;
        }
    }

    public inline function hasAffect(k:Affect) {
        return isAlive() && affects.exists(k) && affects.get(k) > 0;
    }

    public inline function getAffectDurationS(k:Affect) {
        return hasAffect(k) ? affects.get(k) : 0.;
    }

    /** Add an Affect. If `allowLower` is TRUE, it is possible to override an existing Affect with a shorter duration. **/
    public function setAffectS(k:Affect, t:Float, allowLower = false) {
        if (!isAlive() || affects.exists(k) && affects.get(k) > t && !allowLower)
            return;

        if (t <= 0)
            clearAffect(k);
        else {
            var isNew = !hasAffect(k);
            affects.set(k, t);
            if (isNew)
                onAffectStart(k);
        }
    }

    /** Multiply an Affect duration by a factor `f` **/
    public function mulAffectS(k:Affect, f:Float) {
        if (hasAffect(k))
            setAffectS(k, getAffectDurationS(k) * f, true);
    }

    public function clearAffect(k:Affect) {
        if (hasAffect(k)) {
            affects.remove(k);
            onAffectEnd(k);
        }
    }

    /** Affects update loop **/
    function updateAffects() {
        if (!isAlive())
            return;

        for (k in affects.keys()) {
            var t = affects.get(k);
            t -= 1 / Const.FPS * tmod;
            if (t <= 0)
                clearAffect(k);
            else
                affects.set(k, t);
        }
    }

    function onAffectStart(k:Affect) {}

    function onAffectEnd(k:Affect) {}

    /** Return TRUE if the entity is active and has no status affect that prevents actions. **/
    public function isConscious() {
        return !hasAffect(Stun) && isAlive();
    }

    /** Blink `spr` briefly (eg. when damaged by something) **/
    public function blink(c:Col) {

    }

    public function shakeS(xPow:Float, yPow:Float, t:Float) {
        cd.setS("shaking", t, true);
        shakePowX = xPow;
        shakePowY = yPow;
    }

    /** Briefly squash sprite on X (Y changes accordingly). "1.0" means no distorsion. **/
    public function setSquashX(scaleX:Float) {
        sprSquashX = scaleX;
        sprSquashY = 2 - scaleX;
    }

    /** Briefly squash sprite on Y (X changes accordingly). "1.0" means no distorsion. **/
    public function setSquashY(scaleY:Float) {
        sprSquashX = 2 - scaleY;
        sprSquashY = scaleY;
    }

    /**
		"Beginning of the frame" loop, called before any other BaseEntity.Entity update loop
	**/
    public function preUpdate() {
        ucd.update(utmod);
        cd.update(tmod);
        updateAffects();
        updateActions();

        #if debug
		// Display the list of active "affects" (with `/set affect` in console)
		if (ui.Console.ME.hasFlag(F_Affects)) {
			var all = [];
			for (k in affects.keys())
				all.push(k + "=>" + M.pretty(getAffectDurationS(k), 1));
			debug(all);
		}

		// Show bounds (with `/bounds` in console)
		if (ui.Console.ME.hasFlag(F_Bounds) && debugBounds == null)
			enableDebugBounds();

		// Hide bounds
		if (!ui.Console.ME.hasFlag(F_Bounds) && debugBounds != null)
			disableDebugBounds();
		#end
    }

    /**
		Post-update loop, which is guaranteed to happen AFTER any preUpdate/update. This is usually where render and display is updated
	**/
    public function postUpdate() {

        sprSquashX += (1 - sprSquashX) * M.fmin(1, 0.2 * tmod);
        sprSquashY += (1 - sprSquashY) * M.fmin(1, 0.2 * tmod);

        // Blink
        if (!cd.has("keepBlink")) {
            blinkColor.r *= Math.pow(0.60, tmod);
            blinkColor.g *= Math.pow(0.55, tmod);
            blinkColor.b *= Math.pow(0.50, tmod);
        }

        // Color adds
        /*spr.colorAdd.load(baseColor);
		spr.colorAdd.r += blinkColor.r;
		spr.colorAdd.g += blinkColor.g;
		spr.colorAdd.b += blinkColor.b;*/

        // Debug label
        if (debugLabel != null) {
            debugLabel.x = Std.int(attachX - debugLabel.textWidth * 0.5);
            debugLabel.y = Std.int(attachY + 1);
        }

        // Debug bounds
        if (debugBounds != null) {
            if (invalidateDebugBounds) {
                invalidateDebugBounds = false;
                renderDebugBounds();
            }
            debugBounds.x = Std.int(attachX);
            debugBounds.y = Std.int(attachY);
        }
    }

    /**
		Loop that runs at the absolute end of the frame
	**/
    public function finalUpdate() {
        prevFrameAttachX = attachX;
        prevFrameAttachY = attachY;
    }

    final function updateLastFixedUpdatePos() {
        lastFixedUpdateX = attachX;
        lastFixedUpdateY = attachY;
    }

    function onTouchWall(wallX:Int, wallY:Int) {}

    /** Called at the beginning of each X movement step **/
    function onPreStepX() {
        if (xr < 0.3 && level.hasCollision(cx - 1, cy)) {
            xr = 0.3;
            onTouchWall(-1, 0);
        }

        if (xr > 0.7 && level.hasCollision(cx + 1, cy)) {
            xr = 0.7;
            onTouchWall(1, 0);
        }
    }

    /** Called at the beginning of each Y movement step **/
    function onPreStepY() {
        if (yr < 0.6 && level.hasCollision(cx, cy - 1)) {
            yr = 0.6;
            onTouchWall(0, -1);
        }

        if (yr > 0.7 && level.hasCollision(cx, cy + 1)) {
            yr = 0.7;
            onTouchWall(0, 1);
        }
    }

    /**
		Main loop, but it only runs at a "guaranteed" 30 fps (so it might not be called during some frames, if the app runs at 60fps). This is usually where most gameplay elements affecting physics should occur, to ensure these will not depend on FPS at all.
	**/
    public inline function fastDistPx(e:BaseEntity):Float {
        return M.fabs(attachX - e.attachX) + M.fabs(attachY - e.attachY);
    }

    public inline function isMoving() {
        return isAlive() && (M.fabs(dxTotal) >= 0.03 || M.fabs(dyTotal) >= 0.03);
    }

    function onTouchEntity(e:BaseEntity) {
        /*
        if (e.circularWeightBase > 0 && circularWeightBase > 0) {
            var repel = 0.06;
            if (fastDistPx(e) < circularRadius + e.circularRadius) {
                var a = Math.atan2(attachY - e.attachY, attachX - e.attachX);
                vBase.dx += Math.cos(a) * repel;
                vBase.dy += Math.sin(a) * repel;
            }
        }
*/
    }

    function onCircularCollision(with:BaseEntity) {}

    public var moveSpeed:Float = 0.01 ;

    function getMoveSpeed() {
        return moveSpeed;
    }

    function getCircularCollWeight() {
        return circularWeightBase * (0.3);
    }

    function hasCircularCollisions() {
        return !destroyed && circularWeightBase > 0;
    }

    public function fixedUpdate() {
        @:inline updateLastFixedUpdatePos();

        /*
			Stepping: any movement greater than 33% of grid size (ie. 0.33) will increase the number of `steps` here. These steps will break down the full movement into smaller iterations to avoid jumping over grid collisions.
		 */

        var d = 0.;
        var a = 0.;
        var repel = 0.06;
        var wRatio = 0.;
        for (e in ALL) {
            if (e == this)
                continue;

            if (@:inline fastDistPx(e) > Const.GRID * 2)
                continue;

            d = M.dist(attachX, attachY, e.attachX, e.attachY);
            if (d > circularRadius + e.circularRadius)
                continue;

            onTouchEntity(e);

            if (!@:inline hasCircularCollisions() || !e.hasCircularCollisions())
                continue;
            onCircularCollision(e);


            a = Math.atan2(e.attachY - attachY, e.attachX - attachX);
            wRatio = getCircularCollWeight() / (getCircularCollWeight() + e.getCircularCollWeight());
            e.vBase.dx += Math.cos(a) * repel * wRatio;
            e.vBase.dy += Math.sin(a) * repel * wRatio;

            // wRatio = e.getCircularCollWeight() / ( getCircularCollWeight() + e.getCircularCollWeight() );
            // dx -= Math.cos(a)*repel * wRatio;
            // dy -= Math.sin(a)*repel * wRatio;

            // e.onCircularCollision(this);
        }
        if (@:inline canMoveToTarget()) {
            var d = distPx(moveTarget.levelX, moveTarget.levelY);
            if (d > 2) {
                var a = Math.atan2(moveTarget.levelY - attachY, moveTarget.levelX - attachX);
                var s = getMoveSpeed() * M.fmin(1, d / brakeDist);
                vBase.dx += Math.cos(a) * s;
                vBase.dy += Math.sin(a) * s;
            } else
                cancelMove();

            // Brake near target
            if (d <= brakeDist) {
                vBase.dx *= 0.8;
                vBase.dy *= 0.8;
            }
        }

        var steps = M.ceil((M.fabs(dxTotal) + M.fabs(dyTotal)) / 0.33);
        if (steps > 0) {
            var n = 0;
            while (n < steps) {
                // X movement
                xr += dxTotal / steps;

                if (dxTotal != 0)
                    onPreStepX(); // <---- Add X collisions checks and physics in here

                while (xr > 1) {
                    xr--;
                    cx++;
                }
                while (xr < 0) {
                    xr++;
                    cx--;
                }

                // Y movement
                yr += dyTotal / steps;

                if (dyTotal != 0)
                    onPreStepY(); // <---- Add Y collisions checks and physics in here

                while (yr > 1) {
                    yr--;
                    cy++;
                }
                while (yr < 0) {
                    yr++;
                    cy--;
                }

                n++;
            }
        }

        vBase.dx *= 0.82;
        vBump.dx *= 0.82;
        if (M.fabs(vBase.dx) <= 0.0005)
            vBase.dx = 0;
        if (M.fabs(vBump.dx) <= 0.0005)
            vBump.dx = 0;

        // Y frictions
        vBase.dy *= 0.82;
        vBump.dy *= 0.82;
        if (M.fabs(vBase.dy) <= 0.0005)
            vBase.dy = 0;
        if (M.fabs(vBump.dy) <= 0.0005)
            vBump.dy = 0;
    }

    /**
		Main loop running at full FPS (ie. always happen once on every frames, after preUpdate and before postUpdate)
	**/
    public function frameUpdate() {}
}
