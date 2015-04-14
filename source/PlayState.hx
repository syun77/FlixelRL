package;

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
		var func = function(i:Int, j:Int, v:Int) {
			if(v == 3) {
				trace('${i}, ${j}');
			}
		}

		layer.forEach(func);


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