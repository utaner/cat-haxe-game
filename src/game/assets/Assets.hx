package assets;

import dn.heaps.slib.*;
import assets.World;
import h2d.Tile;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
typedef AttachInfo = {rot:Bool, x:Int, y:Int}

class Assets {
    public static var SLIB = dn.heaps.assets.SfxDirectory.load("sfx", true) ;

    // Fonts
    public static var fontPixel:h2d.Font;
    public static var fontPixelMono:h2d.Font;

    /** Main atlas **/
    public static var tiles:SpriteLib;

    /** LDtk world data **/
    public static var worldData:World;

    public static var drone:SpriteLib;
    public static var character:SpriteLib;
    public static var mouse:SpriteLib;
    public static var mouseaxe:SpriteLib;
    public static var particle:SpriteLib;
    public static var particle2:SpriteLib;
    public static var particle3:SpriteLib;
    public static var all_entity:SpriteLib;


    static var _initDone = false ;
    static var characterAttachPts:Map<String, Map<Int, AttachInfo>>;

    public static function init() {
        if (_initDone)
            return;
        _initDone = true;

        // Fonts
        fontPixel = new hxd.res.BitmapFont(hxd.Res.fonts.pixel_unicode_regular_12_xml.entry).toFont();
        fontPixelMono = new hxd.res.BitmapFont(hxd.Res.fonts.pixica_mono_regular_16_xml.entry).toFont();

        // build sprite atlas directly from Aseprite file
        tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());
        drone = new SpriteLib([Tile.fromColor(0, 0, 0, 0)]);
        character = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.character.toAseprite());
        mouse = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.mouse.toAseprite());
        mouseaxe = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.mouse_axe.toAseprite());
        particle = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.particle.toAseprite());
        particle2 = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.particle2.toAseprite());
        particle3 = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.particle3.toAseprite());
        all_entity = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.entity.toAseprite());

        characterAttachPts = new Map();
        var pixels = character.tile.getTexture().capturePixels();
        var attachCol = Col.fromInt(0xff00ff).withAlpha(1);
        var attachRotCol = Col.fromInt(0xff0000).withAlpha(1);
        var p = 0x0;
        for (g in character.getGroups()) {
            var i = 0;
            for (f in g.frames) {
                for (y in 0...f.hei)
                    for (x in 0...f.wid) {
                        p = pixels.getPixel(f.x + x, f.y + y);
                        if (p == attachCol || p == attachRotCol) {
                            if (!characterAttachPts.exists(g.id))
                                characterAttachPts.set(g.id, new Map());
                            characterAttachPts.get(g.id).set(i, {rot: p == attachRotCol, x: x, y: y});
                        }
                    }
                i++;
            }
        }

        // Hot-reloading of CastleDB
        #if debug
		hxd.Res.data.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("cdb");
			App.ME.delayer.addS("cdb", function() {
				CastleDb.load(hxd.Res.data.entry.getBytes().toString());
				Const.db.reload_data_cdb(hxd.Res.data.entry.getText());
			}, 0.2);
		});
		#end

        // Parse castleDB JSON
        CastleDb.load(hxd.Res.data.entry.getText());

        // Hot-reloading of `const.json`
        hxd.Res.const.watch(function() {
            // Only reload actual updated file from disk after a short delay, to avoid reading a file being written
            App.ME.delayer.cancelById("constJson");
            App.ME.delayer.addS("constJson", function() {
                Const.db.reload_const_json(hxd.Res.const.entry.getBytes().toString());
            }, 0.2);
        });

        // LDtk init & parsing
        worldData = new World();

        // LDtk file hot-reloading
        #if debug
		var res = try hxd.Res.load(worldData.projectFilePath.substr(4)) catch (_) null; // assume the LDtk file is in "res/" subfolder
		if (res != null)
			res.watch(() -> {
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
				App.ME.delayer.cancelById("ldtk");
				App.ME.delayer.addS("ldtk", function() {
					worldData.parseJson(res.entry.getText());
					if (Game.exists())
						Game.ME.onLdtkReload();
				}, 0.2);
			});
		#end
    }

    /**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
    public static inline function getAttach(group:String, frame:Int):Null<AttachInfo> {
        return characterAttachPts.exists(group)
        && characterAttachPts.get(group).exists(frame) ? characterAttachPts.get(group).get(frame) : null;
    }

    public static function update(tmod:Float) {
        if (Game.exists() && Game.ME.isPaused())
            tmod = 0;

        tiles.tmod = tmod;
        character.tmod = tmod;
        // <-- add other atlas TMOD updates here
    }
}
