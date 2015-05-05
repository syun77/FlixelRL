package ;

import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;

/**
 * ダメージエフェクト
 **/
class ParticleDamage extends FlxText {

	// パーティクル管理
	public static var parent:FlxTypedGroup<ParticleDamage>;
	public static function start(X:Float, Y:Float, val:Int):Void {
		var p:ParticleDamage = parent.recycle();
		p.x = X;
		p.y = Y;
		p.init(val);
	}

	private var _timer:Int;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super(0, 0, 128);
		// フォント読み込み
		setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);

		// 非表示にしておく
		kill();
	}

	/**
	 * 初期化
	 **/
	public function init(val:Int) {
		text = '${val}';
		_timer = 60;
	}

	/**
	 * コンストラクタ
	 **/
	override public function update():Void {
		super.update();
		_timer--;
		if(_timer < 1) {
			kill();
		}
	}
}
