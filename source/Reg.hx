package;

import flixel.FlxG;
import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	// フォントのパス
	public static inline var PATH_FONT = "assets/font/PixelMplus10-Regular.ttf";

	// フォントサイズ
	public static inline var FONT_SIZE = 20;

	// UI領域
	public static inline var UI_WIDTH = 212;

	// ゲーム領域の中心座標を取得する
	public static function centerX():Float {
		return (FlxG.width - UI_WIDTH) / 2;
	}
	public static function centerY():Float {
		return FlxG.height / 2;
	}

	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];
}