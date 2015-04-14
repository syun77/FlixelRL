package ;

import flixel.FlxSprite;

/**
 * 壁
 **/
class Wall extends FlxSprite {
	public function new(X:Float, Y:Float) {
		super(X, Y);
		loadGraphic("assets/images/wall1.png");
	}
}
