package ;
import flixel.FlxSprite;

/**
 * 敵クラス
 **/
class Enemy extends FlxSprite {

	// 敵ID
	private var _id:Int = 1;

	// 移動元座標
	private var _xprev:Float = 0;
	private var _yprev:Float = 0;
	// 移動先座標
	private var _xnext:Float = 0;
	private var _ynext:Float = 0;

	// プロパティ
	// 敵ID
	public var id(get_id, null):Int;
	private function get_id() {
		return _id;
	}
	// チップ座標(X)
	public var xchip(get_xchip, null):Int;
	private function get_xchip() {
		return Std.int(_xnext);
	}
	// チップ座標(Y)
	public var ychip(get_ychip, null):Int;
	private function get_ychip() {
		return Std.int(_ynext);
	}

	public function new() {
		super();
		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// 消しておく
		kill();
	}

	/**
	 * 初期化
	 **/
	public function init(X:Int, Y:Int, id:Int):Void {
		// アニメーション再生開始
		animation.play(Std.string(id));
		_id = id;

		// 座標反映
		_xprev = X;
		_yprev = Y;
		_xnext = X;
		_ynext = Y;
		x = Field.toWorldX(X);
		y = Field.toWorldY(Y);
	}

	/**
	 * アニメーションの登録
	 **/
	private function _registAnim():Void {
		// 敵画像をアニメーションとして読み込む
		loadGraphic("assets/images/enemy.png", true);

		// アニメーションを登録
		var speed = 2;
		animation.add("1", [0, 1], speed); // スライム
		animation.add("2", [2, 3], speed); // コウモリ
		animation.add("3", [4, 5], speed); // ゴースト
		animation.add("4", [6, 7], speed); // ヘビ
		animation.add("5", [8, 9], speed); // ドクロ
	}
}
