package ;

import DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 状態
 **/
enum State {
	KeyInput; // キー入力待ち
	Standby;  // 待機中
	Move;     // 移動中
	TurnEnd;  // ターン終了
}

/**
 * 共通キャラクタークラス
 **/
class Actor extends FlxSprite {

	// 1マス進むのにかかるフレーム数
	private static inline var TIMER_WALK:Int = 16;

	// 状態
	private var _state:State;
	private var _tMove:Int = 0;
	// 向き
	private var _dir:Dir = Dir.Down;
	// アニメーション状態
	private var _bStop = true;
	// 移動元座標
	private var _xprev:Float = 0;
	private var _yprev:Float = 0;
	// 移動先座標
	private var _xnext:Float = 0;
	private var _ynext:Float = 0;
	// ステータスパラメータ
	private var _params:Params;

	// プロパティ
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
	// 方向
	public var dir(get_dir, null):Dir;
	private function get_dir() {
		return _dir;
	}
	// パラメータ
	public var params(get_params, null):Params;
	private function get_params() {
		return _params;
	}

	public function new() {
		super();
	}

	/**
	 * 初期化
	 **/
	public function init(X:Int, Y:Int, dir:Dir, params:Params):Void {
		_xprev = X;
		_yprev = Y;
		_xnext = X;
		_ynext = Y;
		x = Field.toWorldX(X);
		y = Field.toWorldY(Y);

		_state = State.KeyInput;
		_tMove = 0;
		// 向き
		_dir = dir;
		// ステータス
		_params = params;
	}

	// キー入力待ち状態かどうか
	public function isKeyInput():Bool {
		return _state == State.KeyInput;
	}
	// ターン終了しているかどうか
	public function isTurnEnd():Bool {
		return _state == State.TurnEnd;
	}
	// ターン終了
	public function turnEnd():Void {
		_state = State.KeyInput;
	}

	/**
	 * 更新・歩く
	 **/
	private function _updateWalk():Bool {
		// 経過フレームの割合を求める
		var t = _tMove / TIMER_WALK;
		// 移動方向を求める
		var dx = _xnext - _xprev;
		var dy = _ynext - _yprev;
		// 座標を線形補間する
		x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
		y = Field.toWorldY(_yprev) + (dy * Field.GRID_SIZE) * t;
		_tMove++;
		if(_tMove >= TIMER_WALK) {
			// 移動完了
//			_state = State.TurnEnd;
			_xprev = _xnext;
			_yprev = _ynext;
			return true;
		}
		else {
			// 移動中
			return false;
		}
	}
}
