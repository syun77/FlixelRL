package ;

import flixel.util.FlxColor;
import DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 状態
 **/
enum State {
	KeyInput;  // キー入力待ち
	Standby;   // 待機中
	// 行動
	ActBegin;  // 行動開始
	Act;       // 行動中
	ActEnd;    // 行動終了
	// 移動
	MoveBegin; // 移動開始
	Move;      // 移動中
	MoveEnd;   // 移動終了
	// ターン終了
	TurnEnd;   // ターン終了
}

/**
 * 行動タイプ
 **/
enum Action {
	None;    // なし
	Standby; // 待機中
	Act;     // 攻撃
	Move;    // 移動
	TurnEnd; // ターン終了
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
	// 行動先座標
	private var _xtarget:Int = 0;
	private var _ytarget:Int = 0;
	// ステータスパラメータ
	private var _params:Params;
	// ID
	private var _id:Int = 1;
	// 名前
	private var _name:String = "";

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
	// ID
	public var id(get_id, null):Int;
	private function get_id() {
		return _id;
	}
	// パラメータ
	public var params(get_params, null):Params;
	private function get_params() {
		return _params;
	}
	// 名前
	public var name(get_name, null):String;
	private function get_name() {
		return _name;
	}
	// 行動タイプ
	public var action(get_action, null):Action;
	private function get_action() {
		switch(_state) {
			case State.Standby:
				return Action.Standby; // 待機中
			case State.KeyInput:
				return Action.Standby; // 待機中
			case State.ActBegin:
				return Action.Act; // 攻撃開始
			case State.MoveBegin:
				return Action.Move; // 移動開始
			case State.TurnEnd:
				return Action.TurnEnd; // ターン終了
			default:
				// 通常はここにこない
				trace("error");
				return Action.None;
		}
	}

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();
	}

	/**
	 * 初期化
	 **/
	public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool=false):Void {
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
		// ID
		_id = params.id;
	}

	// 行動開始する
	public function beginAction():Void {
		switch(_state) {
		case State.ActBegin:
			_state = State.Act;
		case State.TurnEnd:
			// 何もしない
		default:
			trace('error:${_state}');
		}
	}
	// 移動開始する
	public function beginMove():Void {
		switch(_state) {
			case State.MoveBegin:
				_state = State.Move;
			case State.TurnEnd:
				// 何もしない
			default:
				trace('error:${_state}');
		}
	}

	// ターン終了しているかどうか
	public function isTurnEnd():Bool {
		return _state == State.TurnEnd;
	}
	// ターン終了
	public function turnEnd():Void {
		_state = State.KeyInput;
	}
	// 指定の座標に存在するかどうかをチェックする
	public function checkPosition(xc:Int, yc:Int):Bool {
		if(xc == xchip && yc == ychip) {
			// 座標が一致
			return true;
		}
		// 一致しない
		return false;
	}

	/**
	 * 更新
	 **/
	public function proc():Void {
		// サブクラスで実装する
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
			_xprev = _xnext;
			_yprev = _ynext;
			return true;
		}
		else {
			// 移動中
			return false;
		}
	}

	/**
	 * ダメージを与える
	 **/
	public function damage(val:Int):Bool {
		if(id == 0) {
			Message.push('${name}は${val}ダメージを受けた');
		}
		else {
			Message.push('${name}に${val}ダメージを与えた');
		}

		Particle.start(Particle.PType.Circle, x, y, FlxColor.RED);

		_params.hp -= val;
		if(_params.hp <= 0) {
			// 死亡
			_params.hp = 0;
			return true;
		}

		// 生きている
		return false;
	}
}
