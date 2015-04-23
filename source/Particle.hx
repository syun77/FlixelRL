package ;
import flash.display.BlendMode;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * パーティクルの種類
 **/
enum PType {
	Circle; // 円
	Ring; // リング
}

/**
 * パーティクル
 **/
class Particle extends FlxSprite {

	// パーティクル管理
	public static var parent:FlxTypedGroup<Particle>;
	public static function start(type:PType, X:Float, Y:Float, color:Int):Void {
		switch(type) {
			case PType.Circle:
				var dir = FlxRandom.floatRanged(0, 45);
				for(i in 0...8) {
					var p:Particle = parent.recycle();
					var spd = FlxRandom.floatRanged(100, 400);
					var t = FlxRandom.intRanged(40, 60);
					p.init(type, t, X, Y, dir, spd);
					p.color = color;
					dir += FlxRandom.floatRanged(40, 50);
				}
			case PType.Ring:
					var t = 60;
					var p:Particle = parent.recycle();
					p.init(type, t, X, Y, 0, 0);
					p.color = color;
		}
	}

	// 種別
	private var _type:PType;
	// タイマー
	private var _timer:Int;
	// 開始タイマー
	private var _tStart:Int;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();
		loadGraphic("assets/images/effect.png", true);

		// アニメーション登録
		animation.add('${PType.Circle}', [0], 1);
		animation.add('${PType.Ring}', [1], 2);

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// 加算ブレンド
		blend = BlendMode.ADD;

		// 非表示
		kill();
	}

	/**
	 * 初期化
	 **/
	public function init(type:PType, timer:Int, X:Float, Y:Float, direction:Float, speed:Float):Void {
		_type = type;
		animation.play('${type}');
		_timer = timer;
		_tStart = timer;

		// 座標と速度を設定
		x = X;
		y = Y;
		var rad = FlxAngle.asRadians(direction);
		velocity.x = Math.cos(rad) * speed;
		velocity.y = -Math.sin(rad) * speed;

		// 初期化
		alpha = 1.0;
		switch(_type) {
			case PType.Circle:
				scale.set(0.5, 0.5);
				acceleration.y = 300;
			case PType.Ring:
				scale.set(0, 0);
				acceleration.y = 0;
		}
	}

	/**
	 * 更新
	 **/
	override public function update():Void {
		super.update();

		switch(_type) {
			case PType.Circle:
				_timer--;
				velocity.x *= 0.95;
				velocity.y *= 0.95;
				scale.x *= 0.97;
				scale.y *= 0.97;
			case PType.Ring:
				_timer = Std.int(_timer * 0.93);
				var sc = 3 * (_tStart - _timer) / _tStart;
				scale.set(sc, sc);
				alpha = _timer / _tStart;
		}

		if(_timer < 1) {
			// 消滅
			kill();
		}
	}
}
