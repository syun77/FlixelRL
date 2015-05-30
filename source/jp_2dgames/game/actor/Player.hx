package jp_2dgames.game.actor;

import flash.display.BlendMode;
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

  // プレイヤーの名前
  private static inline var NAME:String = "プレイヤー";
  // 1ターンの自動回復HP割合
  private static inline var AUTOHEAL_RATIO:Int = 3;

  private var _target:Enemy = null;
  private var _csv:CsvLoader = null;

  // 階段の上に乗っているかどうか
  private var _bOnStairs:Bool;
  public var isOnStairs(get, never):Bool;
  private function get_isOnStairs() {
    return _bOnStairs;
  }
  // 階段の上に乗ったフラグをリセットする
  public function endOnStairs() {
    _bOnStairs = false;
  }

  // 攻撃力
  public var atk(get, never):Int;
  private function get_atk() {
    var weapon = Inventory.getWeapon();
    if(weapon == ItemUtil.NONE) {
      // 何も装備していない
      return 0;
    }
    var atk = ItemUtil.getParam(weapon, "atk");
    return atk;
  }
  // 守備力
  public var def(get, never):Int;
  private function get_def() {
    var armor = Inventory.getArmor();
    if(armor == ItemUtil.NONE) {
      // 何も装備していない
      return 0;
    }
    var def = ItemUtil.getParam(armor, "def");
    return def;
  }

  // 攻撃カーソル
  private var _cursor:FlxSprite;
  public var cursor(get, never):FlxSprite;
  private function get_cursor() {
    return _cursor;
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
    _name = NAME;

    // アニメーションを登録
    _registAnim();

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // キー入力待ち状態にする
    _change(Actor.State.KeyInput);
    _stateprev = _state;

    // 階段の上にいるフラグ
    _bOnStairs = false;

    // 攻撃カーソル生成
    _cursor = new FlxSprite().loadGraphic("assets/images/cursor.png", true);
    _cursor.animation.add("play", [0, 1], 6);
    _cursor.animation.play("play");
    _cursor.visible = false;
    _cursor.offset.set(_cursor.width/2, _cursor.height/2);
  }

  // 初期化
  override public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool = false):Void {
    if(bCreate) {
      // 初回の初期化を行う (Lv1のパラメータが初期化用）
      params.hpmax = _csv.getInt(1, "hp");
      params.hp = params.hpmax;
      params.str = _csv.getInt(1, "str");
      params.vit = _csv.getInt(1, "vit");
    }
    super.init(X, Y, dir, params, bCreate);
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
    if(params.lv >= 99) {
      // レベル99で打ち止め
      return;
    }

    var bLevelUp = false;
    var nextExp = _csv.getInt(params.lv+1, "exp");
    while(params.exp >= nextExp) {
      // レベルアップ
      params.lv++;
      // パラメータ上昇
      _levelup();
      bLevelUp = true;
      if(params.lv >= 99) {
        // レベル99で打ち止め
        break;
      }
      nextExp = _csv.getInt(params.lv+1, "exp");
    }

    if(bLevelUp) {
      // レベルアップメッセージの表示
      Message.push2(Msg.LEVELUP, [name]);
      Message.push2(Msg.LEVELUP2, [name, params.lv]);
    }
  }

  /**
   * レベルアップによるパラメータ上昇
   **/
  private function _levelup():Void {
    // 最大HPを更新
    params.hpmax += _csv.getInt(params.lv, "hp");
    params.str += _csv.getInt(params.lv, "str");
    params.vit += _csv.getInt(params.lv, "vit");
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
        if(Calc.checkHitAttack()) {
          // 攻撃が当たった
          var val = Calc.damage(this, _target, Inventory.getWeapon(), ItemUtil.NONE);
          if(_target.damage(val)) {
            // 敵を倒した
            Message.push2(Msg.ENEMY_DEFEAT, [_target.name]);
            _target.kill();
            // 経験値獲得
            _addExp(_target.params.xp);
            // エフェクト再生
            Particle.start(PType.Ring, _target.x, _target.y, FlxColor.YELLOW);
          }
        }
        else {
          // 攻撃を外した
          Message.push2(Msg.MISS, [_target.name]);
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

  /**
   * 更新
   **/
  override public function proc():Void {

    // カーソル表示チェック
    _checkCursor();

    switch(_state) {
      case Actor.State.KeyInput:
        _updateKeyInput();

      case Actor.State.InventoryOpen:
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
    if(Key.press.A) {
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
      _change(Actor.State.InventoryOpen);
      return;
    }

    if(_isKeyInput() == false) {
      // キー入力をしていない
      return;
    }

    var bAttack = false;
    var dir = DirUtil.getInputDirection();

    if(Key.press.A) {
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
        standby();
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
   * 正面に敵がいるかどうか
   **/
  public function existsEnemyInFront():Bool {

    var bFront = false;
    var pt = FlxPoint.get(_xprev, _yprev);
    {
      DirUtil.move(_dir, pt);
      var i = Std.int(pt.x);
      var j = Std.int(pt.y);
      Enemy.parent.forEachAlive(function(e:Enemy) {
        if(e.checkPosition(i, j)) {
          bFront = true;
        }
      });
    }
    pt.put();

    return bFront;
  }

  /**
   * プレイヤーの目の前に敵がいるかどうかをチェック
   **/
  private function _checkCursor():Void {

    _cursor.visible = existsEnemyInFront();
    if(_cursor.visible) {
      // カーソルを移動
      var pt = FlxPoint.get(_xprev, _yprev);
      {
        DirUtil.move(_dir, pt);
        _cursor.x = Field.toWorldX(pt.x);
        _cursor.y = Field.toWorldY(pt.y);
      }
      pt.put();
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
