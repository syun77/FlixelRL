package;

import flash.geom.Rectangle;
import flixel.util.loaders.CachedGraphics;
import flash.geom.Point;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flash.display.BitmapData;
import jp_2dgames.TmxLoader;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 */
class PlayState extends FlxState
{
	/**
	 * 生成
	 */
	override public function create():Void
	{
		super.create();

		// マップ読み込み
		var tmx = new TmxLoader();
		tmx.load("assets/levels/001.tmx");
		var layer = tmx.getLayer(0);
		var pt:Point = new Point(0, 0);
		var wall:CachedGraphics = new FlxSprite(0, 0, "assets/images/wall1.png").cachedGraphics;
		var w = layer.width * Field.GRID_SIZE;
		var h = layer.height * Field.GRID_SIZE;
		var back = new FlxSprite().makeGraphic(w, h, FlxColor.TRANSPARENT);
		var rect = new Rectangle(0, 0, Field.GRID_SIZE, Field.GRID_SIZE);
		var func = function(i:Int, j:Int, v:Int) {
			pt.x = i*Field.GRID_SIZE;
			pt.y = j*Field.GRID_SIZE;
			if(v == 3) {
				back.pixels.copyPixels(wall.bitmap, rect, pt);
			}
		}
		layer.forEach(func);
		back.dirty = true;
		back.updateFrameData();
		this.add(back);

		// プレイヤー生成
		var player = new Player(16, 16);
		this.add(player);
		FlxG.watch.add(player, "x");
		FlxG.watch.add(player, "y");
		FlxG.watch.add(player, "_xprev");
		FlxG.watch.add(player, "_yprev");
		FlxG.watch.add(player, "frameWidth");
		FlxG.watch.add(player, "width");

//		FlxG.debugger.visible = true;
		FlxG.debugger.toggleKeys = ["ALT"];
//		FlxG.debugger.drawDebug = true;
	}

	/**
	 * 破棄
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * 更新
	 */
	override public function update():Void
	{
		super.update();

		if(FlxG.keys.justPressed.ESCAPE) {
			// ESCキーで終了する
			throw "Terminate.";
		}
	}
}