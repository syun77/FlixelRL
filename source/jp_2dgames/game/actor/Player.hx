package jp_2dgames.game.actor;

import jp_2dgames.game.util.Key;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.NightmareMgr.NightmareSkill;
import flixel.util.FlxRandom;
import jp_2dgames.game.gui.InventoryUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.ParticleMessage;
import flixel.FlxG;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.particle.Particle.PType;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.util.DirUtil.Dir;
import flixel.util.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 踏みつけているチップ
 **/
enum StompChip {
  None;   // 何もない
  Stairs; // 階段
  Shop;   // ショップ
}

/**
 * プレイヤー
 */
class Player extends Actor {

  // プレイヤーの名前
  private static inline var NAME:String = "プレイヤー";
  // 1ターンの自動回復HP割合
  private static inline var AUTOHEAL_RATIO:Int = 2;

  private var _target:Enemy = null;
  private var _csv:CsvLoader = null;

  // 踏みつけているチップ
  private var _stompChip = StompChip.None;
  public var stompChip(get, never):StompChip;
  private function get_stompChip() {
    return _stompChip;
  }
  // 踏みつけているチップをリセットする
  public function endStompChip() {
    _stompChip = StompChip.None;
  }

  // 自動回復フラグ
  private var _bAutoRecovery:Bool = true;

  // 足踏みタイマー
  private var _tFoot:Int = 0;

  // 攻撃力
  public var atk(get, never):Int;
  private function get_atk() {
    var weapon = Inventory.getWeaponData();
    if(weapon == null) {
      // 何も装備していない
      return 0;
    }
    var atk = ItemUtil.getParam(weapon.id, "atk");
    atk += weapon.param.value;
    return atk;
  }
  // 守備力
  public var def(get, never):Int;
  private function get_def() {
    var armor = Inventory.getArmorData();
    if(armor == null) {
      // 何も装備していない
      return 0;
    }
    var def = ItemUtil.getParam(armor.id, "def");
    def += armor.param.value;
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
    // 名前を設定
    _name = NAME;

    // アニメーションを登録
    _registAnim();

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // キー入力待ち状態にする
    _change(Actor.State.KeyInput);
    _stateprev = _state;

    // 踏みつけているチップ
    _stompChip = StompChip.None;

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

    // プレイヤーはID「0」にしておく
    _id = 0;
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

  override public function addExp(v:Int):Void {
    super.addExp(v);
    if(params.lv >= 99) {
      // レベル99で打ち止め
      return;
    }

    var bLevelUp = false;
    var nextExp = _csv.getInt(params.lv+1, "exp");
    while(params.exp >= nextExp) {
      // レベルアップ
      params.lv++;
      // 演出開始
      {
        ParticleMessage.start(x, y, "LEVEL UP");
        Snd.playSe("levelup", true);
      }
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
      var x2:Float = Field.toWorldX(_xtarget);
      var y2:Float = Field.toWorldY(_ytarget);

      // 攻撃終了の処理
      var cbEnd = function(tween:FlxTween) {
        _change(Actor.State.TurnEnd);
      }

      // 攻撃開始の処理
      var cbStart = function(tween:FlxTween) {
        // 攻撃開始
        if(_target == null) {
          // 壁破壊
          var tx = _xtarget;
          var ty = _ytarget;
          if(Field.isWall(tx, ty)) {
            // 壁が壊せる
            Field.breakWall(tx, ty);
            // 使用回数減少
            var val = FlxRandom.intRanged(2, 5);
            if(Inventory.degradeEquipment(IType.Weapon, val)) {
              // 武器破壊
              ParticleMessage.start(x, y, "BROKEN", FlxColor.RED);
            }
          }
          else if(Field.isBlock(tx, ty)) {
            // ブロックが壊せる
            Field.breakWall(tx, ty);
          }
        }
        else {
          if(Calc.checkHitAttack(_target)) {
            // 攻撃が当たった
            var val = Calc.damage(this, _target, Inventory.getWeaponData(), null);
            if(_target.damage(val)) {
              // 敵を倒した
              _target.effectDestroyEnemy();
            }
          }
          else {
            // 攻撃を外した
            Snd.playSe("avoid");
            Message.push2(Msg.MISS, [_target.name]);
          }
        }
        FlxTween.tween(this, {x:x1, y:y1}, 0.1, {ease:FlxEase.expoOut, complete:cbEnd});
      }

      // アニメーション開始
      FlxTween.tween(this, {x:x2, y:y2}, 0.1, {ease:FlxEase.expoIn, complete:cbStart});
    }
    super.beginAction();
  }

  // ターン終了
  override public function turnEnd():Void {
    // 満腹度を減らす
    // 2ターンで1%減る
    var subFoodVal = 0.5;
    if(NightmareMgr.getSkill() == NightmareSkill.Hungry) {
      // 満腹殿減少率が3倍
      subFoodVal *= 3;
    }
    if(subFood(subFoodVal)) {
      // 空腹ダメージ
      // HPが5%減る
      var v = Std.int(params.hpmax * 0.05);
      if(v <= 0) {
        v = 1;
      }
      damage(v);
    }

    // 自動回復が有効かどうか
    var checkFood = function() {
      if(food <= 0) {
        // 空腹時は回復できない
        return false;
      }
      if(_bAutoRecovery == false) {
        // 自動回復無効
        return false;
      }
      if(_badstatus == BadStatus.Sickness) {
        // 病気中は自動回復できない
        return false;
      }
      if(NightmareMgr.getSkill() == NightmareSkill.AutoRecover) {
        // 自動回復無効
        return false;
      }

      // 自動回復可能
      return true;
    }

    if(checkFood()) {
      // 自動回復可能
      var v = AUTOHEAL_RATIO;
      if(badstatus == BadStatus.Powerful) {
        // 元気状態の場合は回復量2倍
        v *= 2;
      }
      addHp2(v, false);
    }
    _bAutoRecovery = true;

    // 毒ダメージ
    if(badstatus == BadStatus.Poison) {
      var v = getPoisonDamage();
      damage(v);
    }

    super.turnEnd();
  }

  /**
   * ダメージを受けた
   **/
  override public function damage(v:Int):Bool {

    // 自動回復無効
    _bAutoRecovery = false;

    // 危険状態のチェック
    var bDanger = isDanger();
    var ret = super.damage(v);
    var check = function() {
      if(bDanger == false && isDanger()) {
        // 危険状態になった
        return true;
      }
      if(v >= params.hpmax * 0.5) {
        // 半分以上HPが減るダメージを受けた
        return true;
      }
      return false;
    }
    if(check()) {
      // 危険状態なので赤フラッシュ
      // 画面を0.2秒間、赤フラッシュします
      FlxG.camera.flash(FlxColor.RED, 0.2);
      Snd.playSe("critical");
    }

    return ret;
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
          switch(Field.getChip(xchip, ychip)) {
            case Field.GOAL:
              // 移動先が階段
              _stompChip = StompChip.Stairs;
            case Field.SHOP:
              // 移動先がお店
              _stompChip = StompChip.Shop;
            case Field.HINT:
              // ヒント表示
              Snd.playSe("hint", true);
              Message.pushHint();
            default:
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
   * バッドステータスチェック
   **/
  private function _checkBadStatus():Bool {
    switch(badstatus) {
      case BadStatus.Sleep, BadStatus.Paralysis:
        // 行動不能
        return true;
      default:
    }

    // 行動不能でない
    return false;
  }

  /**
   * 足踏みチェック
   **/
  private function _checkFoot():Bool {
    if(Key.on.A) {
      if(hpratio < 100) {
        _tFoot++;
        if(_tFoot > 24) {
          // 足踏み
          _tFoot = 22;
          return true;
        }
      }
    }
    else {
      _tFoot = 0;
    }

    return false;
  }

  /**
	 * 更新・キー入力待ち
	 **/
  private function _updateKeyInput():Void {
    _bStop = true;

    // バッドステータスチェック
    if(_checkBadStatus()) {
      // 行動不能
      standby();
      return;
    }

    // 足踏みチェック
    if(_checkFoot()) {
      // 行動終了
      standby();
      return;
    }

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
    var checkRandom = function() {
      if(Key.on.X) {
        // 方向転換時はチェック不要
        return false;
      }
      if(badstatus == BadStatus.Confusion) {
        // 混乱しているときは移動方向がランダム
        return true;
      }

      return false;
    };

    if(checkRandom()) {
      // ランダム移動
      dir = DirUtil.random();
    }

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
      if(e.existsPosition(xnext, ynext)) {
        // 敵がいた
        _target = e;
      }
    });

    if(bAttack) {
      // 攻撃 or 待機
      // 目の前の壁チェック
      var checkBreakWall = function(i:Int, j:Int):Bool {
        var extra = InventoryUtil.getWeaponExtra();
        if(extra == "drill") {
          if(Field.isWall(i, j)) {
            // 壊せる
            return true;
          }
        }
        if(Field.isBlock(i, j)) {
          // 壊せる
          return true;
        }

        // 壊せない
        return false;
      }
      if(checkBreakWall(xnext, ynext)) {
        // 壁を攻撃する
        _target = null;
        _xtarget = xnext;
        _ytarget = ynext;
        _change(Actor.State.ActBegin);
        return;
      }

      if(NightmareMgr.getSkill() == NightmareSkill.Attack) {
        // 通常攻撃不可
        _target = null;
      }

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
    var canWalk = function() {
      var extra = InventoryUtil.getRingExtra();
      return Field.isMove(xnext, ynext, extra, _dir);
    };
    if(canWalk()) {
      // 移動可能
      _xnext = xnext;
      _ynext = ynext;
      _bStop = false;
      _change(Actor.State.MoveBegin);
      _tMove = 0;
      if(Key.on.Y) {
        // 早歩き有効
        _bRun = true;
      }
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
        if(e.existsPosition(i, j)) {
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

  /**
   * 死亡
   **/
  override public function kill():Void {
    Message.push("プレイヤーは力尽きた...");

    // エフェクト再生
    Particle.start(PType.Ring, x, y, FlxColor.YELLOW);

    // 画面を2%の揺れ幅で0.35秒間、揺らします
    FlxG.camera.shake(0.02, 0.35);
    // 画面を0.5秒間、白フラッシュします
    FlxG.camera.flash(0xffFFFFFF, 0.5);
    super.kill();
  }

  /**
   * アイテムをぶつける
   * @param actor アイテムを投げた人
   * @param item ぶつけるアイテム
   * @return 当たったら true / 外れたら false
   **/
  override public function hitItem(actor:Actor, item:ItemData, bAlwaysHit=false):Bool {

    if(bAlwaysHit == false) {
      if(Calc.checkHitThrow(this) == false) {
        // 外した
        Snd.playSe("avoid");
        return false;
      }
    }

    // アイテムヒットした
    if(hitItemEffect(actor, item, true, Inventory.getArmorData())) {
      // 倒された
      // エフェクト再生
      Particle.start(PType.Ring, x, y, FlxColor.YELLOW);

      kill();
    }

    return true;
  }

  /**
   * デバッグ用座標設定
   **/
  public function setDebugPosition(i:Int, j:Int):Void {
    super.init(i, j, dir, params, false);
  }
}
