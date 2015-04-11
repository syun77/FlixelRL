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