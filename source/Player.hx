package ;

import flixel.FlxSprite;
/**
 * プレイヤー
 */
class Player extends FlxSprite {

	/**
	 * 生成
	 */
	public function new(X:Int, Y:Int) {
		super(X, Y, "assets/images/player.png");
	}
}
