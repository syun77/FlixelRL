package jp_2dgames.game.actor;
import jp_2dgames.game.particle.ParticleMessage;
import jp_2dgames.game.NightmareMgr.NightmareSkill;
import jp_2dgames.game.gui.InventoryUtil;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.ParticleSmoke;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.Message;
import flixel.util.FlxRandom;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxTypedGroup;
import jp_2dgames.lib.CsvLoader;
import flixel.util.FlxPoint;
import flixel.FlxG;
import jp_2dgames.game.DirUtil.Dir;
import flixel.FlxSprite;

/**
 * 敵クラス
 **/
class Enemy extends Actor {

  private static inline var HP_BAR_MARGIN_W:Int = 4;
  private static inline var HP_BAR_MARGIN_H:Int = 2;
  private static inline var ID_UNKNOWN = EnemyConst.LEGION;

  // 管理クラス
  public static var parent:FlxTypedGroup<Enemy> = null;
  // プレイヤー
  public static var target:Player = null;
  // 敵パラメータ
  public static var csv:CsvLoader = null;

  /**
   * 敵IDを指定して敵の名前を取得する
   **/
  public static function getNameFromID(eid:Int):String {
    if(csv == null) {
      return "none";
    }

    return csv.searchItem("id", '${eid}', "name");
  }

  /**
   * 敵IDを指定して詳細情報を取得する
   **/
  public static function getDetailFromID(eid:Int):String {
    if(csv == null) {
      return "not description.";
    }

    return csv.searchItem("id", '${eid}', "detail");
  }

  /**
   * 敵を生成する
   **/
  public static function add(eid:Int, xchip:Int, ychip:Int):Enemy {
    var e:Enemy = parent.recycle();

    var params = new Params();
    params.id = eid;
    e.init(xchip, ychip, DirUtil.random(), params, true);

    return e;
  }

  /**
   * 指定の座標に存在する敵を返す
   * @param xchip チップ座標(X)
   * @param ychip チップ座標(Y)
   * @return 存在しない場合は null
   **/
  public static function getFromPosition(xchip:Int, ychip:Int):Enemy {
    var ret:Enemy = null;
    parent.forEachAlive(function(e:Enemy) {
      if(e.existsPosition(xchip, ychip)) {
        ret = e;
      }
    });

    return ret;
  }

  // HPバー
  private var _hpBar:FlxBar;
  public var hpBar(get, null):FlxBar;

  private function get_hpBar() {
    return _hpBar;
  }

  // ナイトメアかどうか
  private var _bNightmare:Bool = false;
  // ナイトメアアニメーション
  private var _tNightmare:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // ダミー画像を読み込み
    _registAnim(1);

    // HPバー生成
    _hpBar = new FlxBar(0, 0, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(width - HP_BAR_MARGIN_W), 4);
    _hpBar.createFilledBar(FlxColor.CRIMSON, FlxColor.CHARTREUSE);

    // 消しておく
    kill();

    //		FlxG.watch.add(this, "_state");
    //		FlxG.watch.add(this, "_stateprev");
  }

  /**
   * 消滅処理
   **/
  override public function kill():Void {
    _hpBar.visible = false;
    _bNightmare = false;
    super.kill();
  }

  /**
   * 弾を発射するかどうかチェック
   **/
  private function _checkShot():Bool {
    var dx = target.xchip - xchip;
    var dy = target.ychip - ychip;
    var dir = Dir.None;
    if(Math.abs(dx) > 1) {
      return true;
    }
    if(Math.abs(dy) > 1) {
      return true;
    }

    return false;
  }

  /**
   * アクション終了時に呼び出される関数
   **/
  private function _cbActionEnd():Void {
    // 消滅時に行動終了にする
    _change(Actor.State.TurnEnd);
  }

  /**
	 * 攻撃開始
	 **/
  override public function beginAction():Void {
    if(_state == Actor.State.ActBegin) {
      // 攻撃アニメーション開始
      if(_checkShot()) {
        // 弾を撃つ
        var itemid = _getCsvParamInt("firearm");
        var p = new ItemExtraParam();
        var item = new ItemData(itemid, p);
        var px = Field.toWorldX(xchip);
        var py = Field.toWorldY(ychip);
        var ms = MagicShot.start(px, py, this, target, item);
        ms.setEndCallback(function() {
          // 消滅時に行動終了にする
          _cbActionEnd();
        });
        super.beginAction();
        return;
      }

      // 通常攻撃
      var x1:Float = x;
      var y1:Float = y;
      var x2:Float = target.x;
      var y2:Float = target.y;
      // 攻撃終了の処理
      var cbEnd = function(tween:FlxTween) {
        _cbActionEnd();
      }

      // 攻撃開始の処理
      var cbStart = function(tween:FlxTween) {
        if(Calc.checkHitAttackFromEnemy(target)) {
          // 攻撃が当たった
          var checkSkill = function() {
            // スキル発動チェック
            if(_badstatus == BadStatus.Closed) {
              // 封印中は無効
              return false;
            }
            var extra = _getCsvParam("extra");
            if(extra == "") {
              // 特殊攻撃なし
              return false;
            }
            var ratio = _getCsvParamInt("ratio");
            if(FlxRandom.chanceRoll(ratio)) {
              // スキル発動
              var extval = _getCsvParamInt("extval");
              ItemUtil.useExtra(target, extra, extval);
              return true;
            }
            return false;
          }
          if(checkSkill() == false) {
            // 通常攻撃
            var val = Calc.damage(this, target, null, Inventory.getArmorData());
            target.damage(val);

            // ナイトメアスキル反映
            if(NightmareMgr.getSkill() == NightmareSkill.WeaponBreak) {
              if(id == NightmareMgr.getEnemyID()) {
                // 武器破壊
                if(Inventory.degradeEquipment(IType.Weapon, 9999)) {
                  // 破壊エフェクト
                  ParticleMessage.start(x, y, "BROKEN", FlxColor.RED);
                }
              }
            }

            // 鎧特殊効果反映
            var extra = InventoryUtil.getArmorExtra();
            if(extra == "counter") {
              // 反撃属性あり
              // 終了関数上書き
              cbEnd = function(tween:FlxTween) {
                var val2 = Std.int(val * 0.3);
                if(val2 < 1) {
                  val2 = 1;
                }
                if(damage(val2)) {
                  // 敵を倒した
                  effectDestroyEnemy();
                }
                _cbActionEnd();
              }
            }
          }
          if(target.existsEnemyInFront() == false) {
            // プレイヤーの正面に敵がいなければ攻撃した敵の方を振り向く
            var pt = FlxPoint.get(_xprev, _yprev);
            DirUtil.move(_dir, pt);
            var i = Std.int(pt.x);
            var j = Std.int(pt.y);
            pt.put();
            if(target.existsPosition(i, j)) {
              target.look(xchip, ychip);
            }
          }
        }
        else {
          // 攻撃が外れた
          Snd.playSe("avoid");
          Message.push2(Msg.MISS, [target.name]);
        }
        FlxTween.tween(this, {x:x1, y:y1}, 0.1, {ease:FlxEase.expoOut, complete:cbEnd});
      }
      FlxTween.tween(this, {x:x2, y:y2}, 0.1, {ease:FlxEase.expoIn, complete:cbStart});
    }

    super.beginAction();
  }

  /**
   * CSVから値を取得する
   **/
  private function _getCsvParam(name:String):String {
    return csv.searchItem("id", '${id}', name);
  }
  private function _getCsvParamInt(name:String):Int {
    return Std.parseInt(_getCsvParam(name));
  }

  /**
	 * 初期化
	 **/
  override public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool = false):Void {

    // アニメーションを登録
    var eid = params.id;
    if(NightmareMgr.getSkill() == NightmareSkill.Unknown) {
      if(NightmareMgr.getEnemyID() != params.id) {
        // アンノウンにする
        eid = ID_UNKNOWN;
      }
    }
    _registAnim(eid);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // ID取得
    _id = params.id;

    if(bCreate) {
      // 生成なのでCSVからパラメータを取得する
      params.hp = _getCsvParamInt("hp");
      params.hpmax = params.hp;
      params.str = _getCsvParamInt("str");
      params.vit = _getCsvParamInt("vit");
    }
    super.init(X, Y, dir, params);
    // 名前を設定
    _name = _getCsvParam("name");
    // 獲得経験値を設定
    params.xp = _getCsvParamInt("xp");

    // アニメーション変更
    _changeAnime();

    // 出現演出
    ParticleSmoke.start("enemy", x, y+height/4);
    Snd.playSe("enemy", true);

    // ナイトメアかどうかをチェック
    if(NightmareMgr.getEnemyID() == params.id) {
      // ナイトメア
      _bNightmare = true;
      _tNightmare = 0;
    }
  }

  /**
   * アンノウンにする
   **/
  public function changeUnknown():Void {
    // 画像変更
    _registAnim(ID_UNKNOWN);

    // 出現演出
    ParticleSmoke.start("enemy", x, y+height/4);
    Snd.playSe("enemy", true);
  }

  /**
   * ターン終了
   **/
  override public function turnEnd():Void {
    if(badstatus == BadStatus.Poison) {
      // 毒ダメージ
      var v = getPoisonDamage();
      if(damage(v)) {
        // 敵を倒した
        Message.push2(Msg.ENEMY_DEFEAT, [name]);
        kill();
        FlxG.sound.play("destroy");
        // 経験値獲得
        ExpMgr.add(params.xp);
        // エフェクト再生
        Particle.start(PType.Ring, x, y, FlxColor.YELLOW);

        return;
      }
    }
    super.turnEnd();
  }

  /**
	 * 更新
	 **/
  override public function update():Void {
    super.update();
    // HPバーの更新
    if(hpratio < 100) {
      _hpBar.visible = true;
      _hpBar.x = x - width / 2 + HP_BAR_MARGIN_W;
      _hpBar.y = y - height / 2 - HP_BAR_MARGIN_H;
      _hpBar.percent = hpratio;
    }
    else {
      // 満タンの場合は表示しない
      _hpBar.visible = false;
    }

    if(_bNightmare) {
      // ナイトメアアニメーション
      _tNightmare++;
      if(_tNightmare < 32 && _tNightmare%6 == 0) {
        // 出現エフェクト
        Particle.start(PType.Ring, x, y, FlxColor.SILVER);
      }
      if(_tNightmare%16 == 0) {
        var dy = height/2;
        Particle.start(PType.Night, x, y+dy, FlxColor.WHITE);
      }
      if(_tNightmare%60 == 0) {
        Particle.start(PType.Ring2, x, y, FlxColor.SILVER);
      }
    }
  }

  /**
	 * 更新
	 **/
  override public function proc():Void {

    switch(_state) {
      case Actor.State.KeyInput:
        // 何もしない

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
          _change(Actor.State.TurnEnd);
        }

      case Actor.State.MoveEnd:
        // 何もしない

      case Actor.State.TurnEnd:
        // 何もしない
    }
  }

  /**
	 * 移動方向を決める
	 **/
  private function _aiMoveDir():Dir {

    if(_badstatus == BadStatus.Confusion) {
      // 混乱しているのでランダム移動
      return DirUtil.random();
    }

    // 移動方向判定
    var player = cast(FlxG.state, PlayState).player;
    var dx = player.xchip - xchip;
    var dy = player.ychip - ychip;
    var func = function() {
      // 水平方向に移動するかどうか
      var bHorizon = Math.abs(dx) > Math.abs(dy);
      if(Math.abs(dx) == Math.abs(dy)) {
        // 水平方向と垂直方向の距離が一緒の場合はランダム移動
        bHorizon = FlxRandom.intRanged(0, 1) == 0;
      }
      if(bHorizon) {
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

    // 移動先がチェックする
    var pt = FlxPoint.get(_xnext, _ynext);
    pt = DirUtil.move(dir, pt);
    var xnext = Std.int(pt.x);
    var ynext = Std.int(pt.y);
    pt.put();

    if(_isMove(xnext, ynext) == false) {
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

    return dir;
  }

  private function _isMove(xnext:Int, ynext:Int):Bool {
    var bHit:Bool = false;
    parent.forEachAlive(function(e:Enemy) {
      if(xnext == e.xchip && ynext == e.ychip) {
        // 移動先に敵がいる
        bHit = true;
      }
    });
    if(bHit) {
      // 敵がいるので移動できない
      return false;
    }

    // 飛行属性を取得する
    var fly = _getCsvParam("fly");
    switch(fly) {
      case "fly":
        // 空を飛んでいる
        if(Field.isThroughFirearm(xnext, ynext) == false) {
          // 飛んでいても抜けられない
          return false;
        }
      case "wall":
        // どんな壁も抜けられる

      default:
        // 通常
        if(Field.isCollision(xnext, ynext)) {
          // 壁なので移動できない
          return false;
        }
    }

    // 移動できる
    return true;
  }

  /**
   * ターゲットに対して攻撃可能かどうか
   **/
  private function _checkAttack():Bool {

    var bAttack = false;

    var range = _getCsvParam("range");
    switch(_badstatus) {
      case BadStatus.Closed:
        // 封印状態
        range = "";
      case BadStatus.Confusion:
        // 混乱状態
        range = "";
      case BadStatus.Anger:
        // 怒り状態
        range = "";
      default:
    }
    switch(range) {
      case "":
        // 上下左右1マス先のみ
        var pt = FlxPoint.get();
        for(dir in [Dir.Left, Dir.Up, Dir.Right, Dir.Down]) {
          pt.set(_xprev, _yprev);
          pt = DirUtil.move(dir, pt);
          if(target.existsPosition(Std.int(pt.x), Std.int(pt.y))) {
            // 近くにプレイヤーがいる
            if(badstatus == BadStatus.Confusion) {
              // 混乱しているときは向きがランダム
              if(DirUtil.random() == _dir) {
                // 攻撃できる
                _dir = dir;
                bAttack = true;
              }
            }
            else {
              // 攻撃できる
              _dir = dir;
              bAttack = true;
            }
            break;
          }
        }
        pt.put();
      case "line":
        // 上下左右のライン攻撃可能
        var pt = FlxPoint.get();
        for(dir in [Dir.Left, Dir.Up, Dir.Right, Dir.Down]) {
          pt.set(_xprev, _yprev);
          while(true) {
            pt = DirUtil.move(dir, pt);
            var px = Std.int(pt.x);
            var py = Std.int(pt.y);
            if(Field.isThroughFirearm(px, py) == false) {
              // 壁に当たったので攻撃できない
              break;
            }
            if(Enemy.getFromPosition(px, py) != null) {
              // 別の敵に当たるので攻撃できない
              break;
            }
            if(target.existsPosition(px, py)) {
              // 攻撃できる
              _dir = dir;
              bAttack = true;
              break;
            }
          }
          if(bAttack) {
            break;
          }
        }
        pt.put();

    }

    return bAttack;
  }

  /**
	 * 移動要求をする
	 **/
  public function requestMove():Void {

    // ■行動可能かどうかをチェック
    var checkActive = function() {
     switch(_badstatus) {
       case BadStatus.Sleep: return false;
       case BadStatus.Paralysis: return false;
       default:
         if(_state == Actor.State.TurnEnd) {
           // ターン終了している
           return false;
         }
         return true;
     }
    }
    if(checkActive() == false) {
      // 動けないのでターン終了
      standby();
      return;
    }

    // ■攻撃可能かどうかをチェック
    if(_checkAttack()) {
      // 攻撃可能
      // 移動方向を反映
      _changeAnime();
      _change(Actor.State.ActBegin);
      return;
    }

    // ■移動方向を決める
    var xnext:Int = Std.int(_xprev);
    var ynext:Int = Std.int(_yprev);
    var pt = FlxPoint.get(_xprev, _yprev);
    switch(_getCsvParam("move")) {
      case "":
        // 追跡AI
        _dir = _aiMoveDir();
        pt = DirUtil.move(_dir, pt);
        xnext = Std.int(pt.x);
        ynext = Std.int(pt.y);
      case "stay":
        // 移動しない
        _dir = _aiMoveDir();
        pt = DirUtil.move(_dir, pt);
        var xc = Std.int(pt.x);
        var yc = Std.int(pt.y);
        if(target.existsPosition(xc, yc)) {
          // 近くにプレイヤーがいるので攻撃
          xnext = xc;
          ynext = yc;
        }
      case "escape":
        // 逃走
        _dir = _aiMoveDir();
        var d = Math.abs(target.xchip - xchip) + Math.abs(target.ychip - ychip);
        if(d < 3) {
          // 近づかれると反転
          _dir = DirUtil.invert(_dir);
        }
        pt = DirUtil.move(_dir, pt);
        xnext = Std.int(pt.x);
        ynext = Std.int(pt.y);
    }
    pt.put();

    // 移動方向を反映
    _changeAnime();

    // 移動先にプレイヤーがいるかどうかをチェック
    if(target.existsPosition(xnext, ynext)) {
      // プレイヤーがいるので攻撃
      _change(Actor.State.ActBegin);
      return;
    }

    // 移動先チェック
    if(_isMove(xnext, ynext)) {
      // 移動可能
      _xnext = xnext;
      _ynext = ynext;
      _change(Actor.State.MoveBegin);
      _tMove = 0;
    }
    else {
      // 移動できないのでターン終了
      _change(Actor.State.TurnEnd);
    }
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
    if(hitItemEffect(actor, item, false, null)) {
      // 倒された
      Message.push2(Msg.ENEMY_DEFEAT, [name]);
      // 経験値獲得
      actor.addExp(params.xp);
      // エフェクト再生
      Particle.start(PType.Ring, x, y, FlxColor.YELLOW);

      kill();
    }

    return true;
  }

  /**
	 * アニメーションの登録
	 **/
  private function _registAnim(eid:Int):Void {
    // 敵画像をアニメーションとして読み込む
    var name = csv.searchItem("id", '${eid}', "image");
    _registAnim2(name);
  }
  private function _registAnim2(name:String):Void {
    loadGraphic('assets/images/monster/${name}.png', true);

    // アニメーションを登録
    var speed = 6;
    animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // 左
    animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // 上
    animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // 右
    animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // 下
  }

  /**
   * アニメーションを切り替える
   **/
  private function _changeAnime():Void {
    var name = DirUtil.toString(_dir);
    animation.play(name);
  }

  /**
   * デバッグ用の座標移動
   **/
  public function setDebugPosition(i:Int, j:Int):Void {
    super.init(i, j, dir, params, false);
  }
}
