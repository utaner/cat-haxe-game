package assets;

/**
	Access to slice names present in Aseprite files (eg. `trace( tiles.fxStar )` ).
	This class only provides access to *names* (ie. String). To get actual h2d.Tile, use Assets class.

	Examples:
	```haxe
	Assets.tiles.getTile( AssetsDictionaries.tiles.mySlice );
	Assets.tiles.getTile( D.tiles.mySlice ); // uses "D" alias defined in "import.hx" file
	```
**/
class AssetsDictionaries {
    public static var tiles = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.tiles) ;
    public static var chr = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.character) ;
    public static var mouse = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.mouse) ;
    public static var mouseaxe = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.mouse_axe) ;
    public static var prc = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.particle) ;
    public static var prc2 = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.particle2) ;
    public static var all_entity = dn.heaps.assets.Aseprite.getDict(hxd.Res.atlas.entity) ;

}