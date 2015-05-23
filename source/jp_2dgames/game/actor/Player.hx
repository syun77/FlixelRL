package jp_2dgames.game.actor;

import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.DirUtil.Dir;
import flixel.util.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * プレイヤー
 */
class Player extends Actor {

  // 1ターンの自動回復HP割合
  private static inline var AUTOHEAL_RATIO:Int = 3;

  private var _target:Enemy = null;
  private var _csv:CsvLoader = null;

  // 階段の上に乗っているかどうか
  private var _bOnStairs:Bool;
  public var isOnStairs(get, null):Bool;

  private function get_isOnStairs() {
    return _bOnStairs;
  }
  // 階段の上に乗ったフラグをリセットする

  public function endOnStairs() {
    _bOnStairs = false;
  }

  /**
	 * 生成
	 */

  public function new(X:Int, Y:Int, csv:CsvLoader) {
    super();

    // CSVを設定
    _csv = csv;

    // 初期化
    Global.initPlayer(this, X, Y, Dir.Down, null);
    // プレイヤーはID「0」にしておく
    _id = 0;
    // 名前を設定
    _name = "プレイヤー";

    // アニメーションを登録
    _registAnim();

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // キー入力待ち状態にする
    _change(Actor.State.KeyInput);
    _stateprev = _state;

    // 階段の上にいるフラグ
    _bOnStairs = false;
  }

  // アニメーション名を取得する

  private function getAnimName(bStop:Bool, dir:Dir):String {
    var pre = bStop ? "stop" : "walk";
    var suf = DirUtil.toString(dir);

    return pre + "-" + suf;
  }

  // アニメーションを再生
  private function changeAnim():Void {
    var name = getAnimName(_bStop, _dir);
    animation.play(name);
  }

  private function _addExp(v:Int):Void {
    addExp(v);

    var bLevelUp = false;
    var nextExp = _csv.getInt(params.lv+1, "exp");
    while(params.exp >= nextExp) {
      // レベルアップ
      params.lv++;
      // パラメータ上昇
      _levelup();
      bLevelUp = true;
      nextExp = _csv.getInt(params.lv+1, "exp");
    }

    if(bLevelUp) {
      Message.push('${name}はレベルアップした');
      Message.push('レベル${params.lv}になった');
    }
  }

  /**
   * レベルアップによるパラメータ上昇
   **/
  private function _levelup():Void {
    // 最大HPを更新
    // TODO: とりあえずHPのみ
    params.hpmax += _csv.getInt(params.lv, "hp");
  }

  /**
	 * 攻撃開始
	 **/
  override public function beginAction():Void {
    if(_state == Actor.State.ActBegin) {
      // 攻撃アニメーション開始
      var x1:Float = x;
      var y1:Float = y;
      var x2:Float = _target.x;
      var y2:Float = _target.y;

      // 攻撃終了の処理
      var cbEnd = function(tween:FlxTween) {
        _change(Actor.State.TurnEnd);
      }

      // 攻撃開始の処理
      var cbStart = function(tween:FlxTween) {
        // 攻撃開始
        var val = Calc.damage(this, _target, jp_2dgames.game.gui.Inventory.getWeapon(), ItemUtil.NONE);
        if(_target.damage(val)) {
          // 敵を倒した
          Message.push2(3, [_target.name]);
          _target.kill();
          // 経験値獲得
          _addExp(_target.params.xp);
          // エフェクト再生
          Particle.start(PType.Ring, _target.x, _target.y, FlxColor.YELLOW);
        }
        FlxTween.tween(this, {x:x1, y:y1}, 0.2, {ease:FlxEase.expoOut, complete:cbEnd});
      }

      // アニメーション開始
      FlxTween.tween(this, {x:x2, y:y2}, 0.2, {ease:FlxEase.expoIn, complete:cbStart});
    }
    super.beginAction();
  }

  // ターン終了

  override public function turnEnd():Void {
    // 満腹度を減らす
    // 10ターンで1%減る
    if(subFood(0.1)) {
      // 空腹ダメージ
      subHp(1);
    }
    if(food > 0) {
      // 空腹でなければHP回復
      addHp2(AUTOHEAL_RATIO);
    }

    super.turnEnd();
  }

  // 更新

  override public function proc():Void {
    switch(_state) {
      case Actor.State.KeyInput:
        _updateKeyInput();

      case Actor.State.Inventory:
        // 何もしない

      case Actor.State.Standby:
        // 何もしない

      case Actor.State.ActBegin:
        // 何もしない

      case Actor.State.Act:
        // Tweenアニメ中

      case Actor.State.ActEnd:
        // 何もしない

      case Actor.State.MoveBegin:
        // 何もしない

      case Actor.State.Move:
        if(_updateWalk()) {
          // 移動完了
          // 階段チェック
          if(Field.getChip(xchip, ychip) == Field.GOAL) {
            // 移動先が階段
            _bOnStairs = true;
          }
          // アイテムがあれば拾う
          DropItem.pickup(xchip, ychip);
          _change(Actor.State.TurnEnd);
        }

      case Actor.State.MoveEnd:
        // 何もしない

      case Actor.State.TurnEnd:
      // 何もしない
    }

    changeAnim();
  }

  /**
	 * キー入力チェック
	 **/

  private function _isKeyInput():Bool {
    if(Key.on.A) {
      // 攻撃 or 待機
      return true;
    }
    if(Key.on.X) {
      // 方向転換のみ
      return true;
    }
    if(DirUtil.getInputDirection() != Dir.None) {
      // 移動した
      return true;
    }

    // 何もしていない
    return false;
  }

  /**
	 * 更新・キー入力待ち
	 **/

  private function _updateKeyInput():Void {
    _bStop = true;

    if(Key.press.B) {
      // メニューを開く
      _change(Actor.State.Inventory);
      return;
    }

    if(_isKeyInput() == false) {
      // キー入力をしていない
      return;
    }

    var bAttack = false;
    var dir = DirUtil.getInputDirection();

    if(Key.on.A) {
      // 攻撃 or 待機
      bAttack = true;
    }
    var bTurn = false;
    if(Key.on.X) {
      // 方向転換のみ
      bTurn = true;
    }
    if(dir != Dir.None) {
      // 向きを反映
      _dir = dir;
    }

    var pt = FlxPoint.get(_xnext, _ynext);
    pt = DirUtil.move(_dir, pt);
    var xnext = Std.int(pt.x);
    var ynext = Std.int(pt.y);
    pt.put();

    // 移動先に敵がいるかどうかチェック
    _target = null;
    Enemy.parent.forEachAlive(function(e:Enemy) {
      if(e.checkPosition(xnext, ynext)) {
        // 敵がいた
        _target = e;
      }
    });

    if(bAttack) {
      // 攻撃 or 待機
      if(_target != null) {
        // 攻撃する
        _xtarget = xnext;
        _ytarget = ynext;
        _change(Actor.State.ActBegin);
      }
      else {
        // 足踏み待機する
        _change(Actor.State.TurnEnd);
      }
      return;
    }

    if(bTurn) {
      // 移動方向を向くだけ
      return;
    }

    if(_target != null) {
      // 移動方向を向くだけ
      return;
    }

    // 移動先チェック
    if(Field.isCollision(xnext, ynext) == false) {
      // 移動可能
      _xnext = xnext;
      _ynext = ynext;
      _bStop = false;
      _change(Actor.State.MoveBegin);
      _tMove = 0;
    }
  }

  /**
	 * アニメーションの登録
	 **/

  private function _registAnim():Void {
    // アニメーションとして読み込む
    loadGraphic("assets/images/player.png", true);

    // アニメーションを登録
    // 待機アニメ
    // アニメーション速度
    var speed = 2;
    animation.add(getAnimName(true, Dir.Left), [0, 1], speed);
    animation.add(getAnimName(true, Dir.Up), [4, 5], speed);
    animation.add(getAnimName(true, Dir.Right), [8, 9], speed);
    animation.add(getAnimName(true, Dir.Down), [12, 13], speed);

    // 歩きアニメ
    speed = 6;
    animation.add(getAnimName(false, Dir.Left), [2, 3], speed);
    animation.add(getAnimName(false, Dir.Up), [6, 7], speed);
    animation.add(getAnimName(false, Dir.Right), [10, 11], speed);
    animation.add(getAnimName(false, Dir.Down), [14, 15], speed);
  }
}
