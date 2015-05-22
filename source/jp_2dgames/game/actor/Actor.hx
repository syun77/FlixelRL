package jp_2dgames.game.actor;

import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.particle.ParticleDamage;
import jp_2dgames.game.gui.Message;
import flixel.util.FlxColor;
import jp_2dgames.game.DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 状態
 **/
enum State {
  KeyInput; // キー入力待ち
  Inventory; // イベントリ
  Standby; // 待機中
  // 行動
  ActBegin; // 行動開始
  Act; // 行動中
  ActEnd; // 行動終了
  // 移動
  MoveBegin; // 移動開始
  Move; // 移動中
  MoveEnd; // 移動終了
  // ターン終了
  TurnEnd;
  // ターン終了
}

/**
 * 行動タイプ
 **/
enum Action {
  None; // なし
  Standby; // 待機中
  Inventory; // インベントリを開く
  Act; // 攻撃
  ActExec; // 攻撃実行中
  Move; // 移動
  MoveExec; // 移動実行中
  TurnEnd;
  // ターン終了
}

/**
 * 共通キャラクタークラス
 **/
class Actor extends FlxSprite {

  // 1マス進むのにかかるフレーム数
  private static inline var TIMER_WALK:Int = 16;
  // ダメージアニメーションのフレーム数
  private static inline var TIMER_DAMAGE:Int = 8;

  // 状態
  private var _state:State;
  private var _stateprev:State; // 1つ前の状態
  private var _tMove:Int = 0;
  // 向き
  private var _dir:Dir = Dir.Down;
  // アニメーション状態
  private var _bStop = true;
  // ダメージ揺らし用のタイマー
  private var _tShake:Int = 0;
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
      case State.Inventory:
        return Action.Inventory; // イベントリを開く
      case State.ActBegin:
        return Action.Act; // 攻撃開始
      case State.Act:
        return Action.ActExec; // 攻撃実行中
      case State.MoveBegin:
        return Action.Move; // 移動開始
      case State.Move:
        return Action.MoveExec; // 移動中
      case State.TurnEnd:
        return Action.TurnEnd; // ターン終了
      default:
        // 通常はここにこない
        trace('error: ${_state}');
        return Action.None;
    }
  }
  // HP
  public var hpratio(get, null):Float;

  private function get_hpratio() {
    return 100 * _params.hp / _params.hpmax;
  }

  public function addHp(val:Int):Void {
    _params.hp += val;
    if(_params.hp > _params.hpmax) {
      _params.hp = _params.hpmax;
    }
  }

  public function addHp2(val:Int):Void {
    // パーセンテージで回復
    var val2 = _params.hpmax * val / 100;
    addHp(Std.int(val2));
  }

  public function subHp(val:Int):Bool {
    _params.hp -= val;
    if(_params.hp <= 0) {
      // 死亡
      _params.hp = 0;
      return true;
    }
    // まだ生きている
    return false;
  }
  // 最大HP

  public function addHpMax(val:Int):Void {
    _params.hpmax += val;
  }

  public function subHpMax(val:Int):Void {
    _params.hpmax -= val;
    if(_params.hp < _params.hpmax) {
      _params.hp = _params.hpmax;
    }
  }
  // 満腹度
  public var food(get, null):Int;

  private function get_food() {
    // 満腹度は100倍
    // 端数切り上げ
    return Std.int(Math.ceil(_params.food / 100));
  }

  public function addFood(ratio:Float):Void {
    _params.food += Std.int(ratio * 100);
    if(_params.food > _params.foodmax) {
      _params.food = _params.foodmax;
    }
  }

  public function subFood(ratio:Float):Bool {
    _params.food -= Std.int(ratio * 100);
    if(_params.food < 0) {
      // 空腹状態
      _params.food = 0;
      return true;
    }
    // まだ満腹度は残っている
    return false;
  }
  // 最大満腹度
  public var foodmax(get, null):Int;
  private function get_foodmax() {
    // 最大満腹度は100倍
    return Std.int(_params.foodmax / 100);
  }

  public function addFoodMax(ratio:Float):Void {
    _params.foodmax += Std.int(ratio * 100);
  }

  public function subFoodMax(ratio:Float):Void {
    _params.foodmax -= Std.int(ratio * 100);
    if(_params.foodmax < _params.food) {
      _params.food = _params.foodmax;
    }
  }

  // 経験値
  public function addExp(exp:Int):Void {
    _params.exp += exp;
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

  public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool = false):Void {
    _xprev = X;
    _yprev = Y;
    _xnext = X;
    _ynext = Y;
    x = Field.toWorldX(X);
    y = Field.toWorldY(Y);

    _state = State.KeyInput;
    _stateprev = _state;
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
        _change(State.Act);
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
        _change(State.Move);
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
    _change(State.KeyInput);
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
  // 状態遷移

  private function _change(next:State):Void {
    _stateprev = _state;
    _state = next;
  }
  // 状態を1つ前に戻す

  public function changeprev():Void {
    var prev = _state;
    _state = _stateprev;
    _stateprev = prev;
  }

  /**
	 * 更新
	 **/

  override public function update():Void {
    super.update();
    if(_tShake > 0) {
      _tShake--;
      var ox = width / 2;
      ox += (_tShake % 4 < 2 ? _tShake : -_tShake) * 2;
      offset.set(ox, height / 2);
    }
  }

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
    _tShake = TIMER_DAMAGE;
    if(id == 0) {
      Message.push2(1, [name, val]);
    }
    else {
      Message.push2(2, [name, val]);
    }

    Particle.start(PType.Circle, x, y, FlxColor.RED);
    ParticleDamage.start(x, y, val);

    if(subHp(val)) {
      // 死亡
      return true;
    }

    // 生きている
    return false;
  }
}
