package jp_2dgames.game.gimmick;

import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  Standby; // 何も起きない
  Almost;  // 次のターンでトゲ出現
  Exec;    // トゲ出現
}

/**
 * マップ上のトラップ
 **/
class Pit extends FlxSprite {

  // ■定数
  private static inline var WAIT_TURN:Int = 3;
  private static inline var TIMER_EXEC:Int = 30;

  // ■static
  // 親
  public static var parent:FlxTypedGroup<Pit> = null;

  public static function start(X:Int, Y:Int):Void {
    var pit:Pit = parent.recycle();
    pit.init(X, Y);
  }

  /**
   * ターン終了
   **/
  public static function turnEnd():Void {
    parent.forEachAlive(function(p:Pit) {
      p._turnEnd();
    });
  }

  /**
   * 足下がスパイクかどうか
   **/
  public static function isSpike(X:Int, Y:Int):Bool {
    var ret = false;
    parent.forEachAlive(function(p:Pit) {
      if(p.xchip == X && p.ychip == Y) {
        if(p._isSpike()) {
          ret = true;
        }
      }
    });
    return ret;
  }

  /**
   * ターン数に対応する状態に変更する
   **/
  public static function setStateFromTurn(turn:Int):Void {
    var t = turn % (WAIT_TURN+1);
    parent.forEachAlive(function(p:Pit) {
      p._setStateFromTurn(t);
    });
  }

  // ■メンバ変数
  private var _state:State;
  private var _tWait:Int = 0;
  private var _timer:Int = 0;

  private var _xchip:Int;
  public var xchip(get, never):Int;
  private function get_xchip() {
    return _xchip;
  }
  private var _ychip:Int;
  public var ychip(get, never):Int;
  private function get_ychip() {
    return _ychip;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic("assets/images/spike.png", true);

    // アニメーション登録
    animation.add('${State.Standby}', [0], 1);
    animation.add('${State.Almost}',  [1], 1);
    animation.add('${State.Exec}',    [2], 1);

    // 中心座標を基準に描画
    offset.set(width / 2, height / 2);

    // いったん消す
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Int, Y:Int):Void {
    _xchip = X;
    _ychip = Y;

    x = Field.toWorldX(X);
    y = Field.toWorldY(Y);

    _change(State.Standby);
  }

  private function _change(s:State):Void {
    _state = s;
    animation.play('${s}');
    switch(s) {
      case State.Standby:
        // ちょっと待つ
        _tWait = WAIT_TURN;
      case State.Almost:
      case State.Exec:
        _timer = TIMER_EXEC;
    }
  }

  public function _turnEnd():Void {
    var player = cast(FlxG.state, PlayState).player;

    switch(_state) {
      case State.Standby:
        _tWait--;
        if(_tWait < 1) {
          _change(State.Almost);
        }
      case State.Almost:
        _change(State.Exec);
        // トゲダメージチェック
        if(player.existsPosition(xchip, ychip)) {
          player.damageSpike();
        }
        Enemy.parent.forEachAlive(function(e:Enemy) {
          if(e.existsPosition(xchip, ychip)) {
            if(e.id == NightmareMgr.getEnemyID()) {
              // ナイトメアはダメージ床の影響を受けない
              e.damage(0);
              return;
            }
            if(e.damageSpike()) {
              // 敵を倒した
              e.effectDestroyEnemy();
            }
          }
        });
      case State.Exec:
        // アニメーションが終了せずにターンが終了した
        _change(State.Standby);
        _tWait--;
    }
  }

  private function _isSpike():Bool {
    return _state == State.Exec;
  }

  override public function update():Void {
    super.update();

    if(_state == State.Exec) {
      _timer--;
      if(_timer < 1) {
        _change(State.Standby);
      }
    }
  }

  private function _setStateFromTurn(turn:Int):Void {
    if(turn == WAIT_TURN) {
      _state = State.Almost;
    }
    else {
      // 待機状態
      _tWait = (WAIT_TURN - turn);
      trace("standby", _tWait);
      _state = State.Standby;
    }
    animation.play('${_state}');
  }
}
