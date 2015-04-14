package;

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