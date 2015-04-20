package ;
import flixel.util.FlxPoint;
import flixel.FlxG;
import DirUtil.Dir;
import flixel.FlxSprite;

///**
// * 状態
// **/
//private enum State {
//	Standby; // 待機中
//	Walk;    // 歩き中
//	TurnEnd; // ターン終了
//}

/**
 * 敵クラス
 **/
class Enemy extends Actor {

//	// 1マス進むのにかかるフレーム数
//	private static inline var TIMER_WALK:Int = 16;
//
//	// 状態
//	private var _state:State = State.Standby;
//	private var _tWalk:Int = 0;

	// 敵ID
	private var _id:Int = 1;

//	// 方向
//	private var _dir:Dir = Dir.Down;
//
//	// 移動元座標
//	private var _xprev:Float = 0;
//	private var _yprev:Float = 0;
//	// 移動先座標
//	private var _xnext:Float = 0;
//	private var _ynext:Float = 0;
//	// ステータスパラメータ
//	private var _params:Params;

	// プロパティ
	// 敵ID
	public var id(get_id, null):Int;
	private function get_id() {
		return _id;
	}
//	// チップ座標(X)
//	public var xchip(get_xchip, null):Int;
//	private function get_xchip() {
//		return Std.int(_xnext);
//	}
//	// チップ座標(Y)
//	public var ychip(get_ychip, null):Int;
//	private function get_ychip() {
//		return Std.int(_ynext);
//	}
//	// ステータスパラメータ
//	public var params(get_params, null):Params;
//	private function get_params() {
//		return _params;
//	}

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
	override public function init(X:Int, Y:Int, dir:Dir, params:Params):Void {

		// ID取得
		var id = params.id;

		// アニメーション再生開始
		animation.play(Std.string(id));
		_id = id;

		super.init(X, Y, Dir.Down, params);

//		// 座標反映
//		_xprev = X;
//		_yprev = Y;
//		_xnext = X;
//		_ynext = Y;
//		x = Field.toWorldX(X);
//		y = Field.toWorldY(Y);
//		_params = params;
	}

	/**
	 * 更新
	 **/
	override public function update():Void {
		super.update();

		switch(_state) {
		case Actor.State.KeyInput:

		case Actor.State.Standby:

		case Actor.State.Walk:
			if(_updateWalk()) {
				_state = Actor.State.TurnEnd;
			}

		case Actor.State.TurnEnd:
		}
	}

//	/**
//	 * ターン終了したかどうか
//	 **/
//	public function isTurnEnd():Bool {
//		return _state == State.TurnEnd;
//	}
//
//	/**
//	 * ターン終了
//	 **/
//	public function turnEnd():Void {
//		_state = State.Standby;
//	}

	/**
	 * 移動方向を決める
	 **/
	private function _aiMoveDir():Dir {
		// 移動方向判定
		var player = cast(FlxG.state, PlayState).player;
		var dx = player.xchip - xchip;
		var dy = player.ychip - ychip;
		var func = function() {
			if(Math.abs(dx) > Math.abs(dy)) {
				if(dx < 0) {
					return Dir.Left;
				}
				else {
					return Dir.Right;
				}
			}
			else {
				if(dy < 0) {
					return Dir.Up;
				}
				else {
					return Dir.Down;
				}
			}
		}

		// 移動方向の判定実行
		var dir = func();

		// 移動先が壁かどうかチェックする
		var pt = FlxPoint.get(_xnext, _ynext);
		pt = DirUtil.move(dir, pt);
		trace(dx, dy);
		trace(pt);
		if(Field.isCollision(Std.int(pt.x), Std.int(pt.y))) {
			// 移動できない
			if(DirUtil.isHorizontal(dir)) {
				if(dy < 0) {
					dir = Dir.Up;
				}
				else {
					dir = Dir.Down;
				}
			}
			else {
				if(dx < 0) {
					dir = Dir.Left;
				}
				else {
					dir = Dir.Right;
				}
			}
		}

		pt.put();
		return dir;
	}

	/**
	 * 移動要求をする
	 **/
	public function requestMove():Void {
		var pt = FlxPoint.get(_xnext, _ynext);
		_dir = _aiMoveDir();
		pt = DirUtil.move(_dir, pt);

		// 移動先チェック
		if(Field.isCollision(Std.int(pt.x), Std.int(pt.y)) == false) {
			// 移動可能
			_xnext = Std.int(pt.x);
			_ynext = Std.int(pt.y);
			_state = Actor.State.Walk;
			_tWalk = 0;
		}
		else {
			// 移動できないのでターン終了
			_state = Actor.State.TurnEnd;
		}

		pt.put();
	}

//	/**
//	 * 更新・歩く
//	 **/
//	private function _updateWalk():Void {
//		// 経過フレームの割合を求める
//		var t = _tWalk / TIMER_WALK;
//		// 移動方向を求める
//		var dx = _xnext - _xprev;
//		var dy = _ynext - _yprev;
//		// 座標を線形補間する
//		x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
//		y = Field.toWorldY(_yprev) + (dy * Field.GRID_SIZE) * t;
//		_tWalk++;
//		if(_tWalk >= TIMER_WALK) {
//			// 移動完了
//			_state = State.TurnEnd;
//			_xprev = _xnext;
//			_yprev = _ynext;
//		}
//	}

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
