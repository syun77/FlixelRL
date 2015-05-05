package ;

import flash.geom.Rectangle;
import flash.geom.Point;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
	Main;  // メイン
	Wait;  // ちょっと待つ
	Blink; // 点滅
}

/**
 * ダメージエフェクト
 **/
class ParticleDamage extends FlxSprite {

	private static inline var FONT_SIZE:Int = 16;

	// パーティクル管理
	public static var parent:FlxTypedGroup<ParticleDamage>;
	public static function start(X:Float, Y:Float, val:Int):Void {
		var p:ParticleDamage = parent.recycle();
		p.init(X, Y, val);
	}

	// 開始座標
	private var _ystart:Float;
	private var _state:State;
	private var _timer:Int;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();

		makeGraphic(FONT_SIZE*8, FONT_SIZE, FlxColor.TRANSPARENT, true);

		// 非表示にしておく
		kill();
	}

	/**
	 * 初期化
	 **/
	public function init(X:Float, Y:Float, val:Int) {
		x = X;
		y = Y;
		_ystart = Y;

		// 描画をクリアする
		pixels.fillRect(new Rectangle(0, 0, FONT_SIZE*8, FONT_SIZE), FlxColor.TRANSPARENT);

		var bmp = FlxG.bitmap.add("assets/font/font16x16.png");
		var pt = new Point();
		var rect = new Rectangle(0, 0, FONT_SIZE, FONT_SIZE);
		var digit = Std.string(val).length;
		trace('digit=${digit} val=${val}');
		for(i in 0...digit) {
			pt.x = (digit - i - 1) * FONT_SIZE;
			trace(pt);
			var v = Std.int(val / Math.pow(10, i)) % 10;
			rect.left = v * FONT_SIZE;
			rect.right = rect.left + FONT_SIZE;
			pixels.copyPixels(bmp.bitmap, rect, pt);
		}
		dirty = true;
		updateFrameData();

		// 指定の位置を中心にするように調整
		x = X - (FONT_SIZE * digit / 2);

		// 移動する
		velocity.y = -200;

		// メイン状態へ
		_state = State.Main;
	}

	/**
	 * コンストラクタ
	 **/
	override public function update():Void {
		super.update();

		switch(_state) {
			case State.Main:
				velocity.y += 15;
				if(y > _ystart) {
					y = _ystart;
					velocity.y *= -0.5;
					trace(velocity.y);
					if(Math.abs(velocity.y) < 30) {
						velocity.y = 0;
						_timer = 30;
						_state = State.Wait;
					}
				}
			case State.Wait:
				// ちょっと待つ
				_timer--;
				if(_timer < 1) {
					_timer = 30;
					_state = State.Blink;
				}
			case State.Blink:
				// 点滅して消える
				visible = (_timer%4 >= 2);
				_timer--;
				if(_timer < 1) {
					kill();
				}
		}

	}
}
