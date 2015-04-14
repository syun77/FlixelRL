package ;

/**
 * フィールド管理
 **/
import flixel.FlxG;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.Layer2D;
class Field {
	// グリッドサイズ
	public static inline var GRID_SIZE:Int = 32;

	// チップの種類
	public static inline var WALL:Int = 3; // 壁

	public static function toWorldX(i:Float):Float {
		return i * GRID_SIZE + GRID_SIZE/2;
	}
	public static function toWorldY(j:Float):Float {
		return j * GRID_SIZE + GRID_SIZE/2;
	}
	public static function toChipX(x:Float):Float {
		return Math.floor((x - GRID_SIZE/2) / GRID_SIZE);
	}
	public static function toChipY(y:Float):Float {
		return Math.floor((y - GRID_SIZE/2) / GRID_SIZE);
	}

	public function new() {
	}

	public static function createBackground(layer:Layer2D):FlxSprite {
		var spr = new FlxSprite();
		var w = layer.width * GRID_SIZE;
		var h = layer.height * GRID_SIZE;
		// チップ画像読み込み
		var chip = FlxG.bitmap.add("assets/images/wall1.png");
		// 透明なスプライトを作成
		spr.makeGraphic(w, h, FlxColor.TRANSPARENT);
		// 転送先の座標
		var pt = new Point();
		// 転送領域の作成
		var rect = new Rectangle(0, 0, GRID_SIZE, GRID_SIZE);
		// 描画関数
		var func = function(i:Int, j:Int, v:Int) {
			pt.x = i * GRID_SIZE;
			pt.y = j * GRID_SIZE;
			if(v == WALL) {
				spr.pixels.copyPixels(chip.bitmap, rect, pt);
			}
		}

		// レイヤーを走査する
		layer.forEach(func);
		spr.dirty = true;
		spr.updateFrameData();

		return spr;
	}
}
