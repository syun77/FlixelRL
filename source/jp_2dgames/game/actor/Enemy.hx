package jp_2dgames.game.actor;
import jp_2dgames.game.gui.Message;
import flixel.util.FlxRandom;
import jp_2dgames.game.item.ItemUtil;
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

  // 管理クラス
  public static var parent:FlxTypedGroup<Enemy> = null;
  // プレイヤー
  public static var target:Player = null;
  // 敵パラメータ
  public static var csv:CsvLoader = null;

  // HPバー
  private var _hpBar:FlxBar;
  public var hpBar(get, null):FlxBar;

  private function get_hpBar() {
    return _hpBar;
  }

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

  override public function kill():Void {
    _hpBar.visible = false;
    super.kill();
  }

  /**
	 * 攻撃開始
	 **/
  override public function beginAction():Void {
    if(_state == Actor.State.ActBegin) {
      // 攻撃アニメーション開始
      var x1:Float = x;
      var y1:Float = y;
      var x2:Float = target.x;
      var y2:Float = target.y;

      // 攻撃終了の処理
      var cbEnd = function(tween:FlxTween) {
        _change(Actor.State.TurnEnd);
      }

      // 攻撃開始の処理
      var cbStart = function(tween:FlxTween) {
        // 攻撃開始
        if(Calc.checkHitAttackForEnemy()) {
          // 攻撃が当たった
          var val = Calc.damage(this, target, ItemUtil.NONE, Inventory.getArmor());
          target.damage(val);
          if(target.existsEnemyInFront() == false) {
            // プレイヤーの正面に敵がいなければ攻撃した敵の方を振り向く
            var pt = FlxPoint.get(_xprev, _yprev);
            DirUtil.move(_dir, pt);
            var i = Std.int(pt.x);
            var j = Std.int(pt.y);
            pt.put();
            if(target.checkPosition(i, j)) {
              target.look(i, j);
            }
          }
        }
        else {
          // 攻撃が外れた
          Message.push2(Msg.MISS, [target.name]);
        }
        FlxTween.tween(this, {x:x1, y:y1}, 0.2, {ease:FlxEase.expoOut, complete:cbEnd});
      }

      FlxTween.tween(this, {x:x2, y:y2}, 0.2, {ease:FlxEase.expoIn, complete:cbStart});
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
    _registAnim(params.id);

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

    if(Field.isCollision(xnext, ynext)) {
      // 壁なので移動できない
      return false;
    }

    // 移動できる
    return true;
  }

  /**
	 * 移動要求をする
	 **/

  public function requestMove():Void {
    var pt = FlxPoint.get(_xnext, _ynext);
    _dir = _aiMoveDir();
    pt = DirUtil.move(_dir, pt);
    var xnext = Std.int(pt.x);
    var ynext = Std.int(pt.y);
    pt.put();

    // 移動方向を反映
    _changeAnime();

    // 移動先にプレイヤーがいるかどうかをチェック
    if(target.checkPosition(xnext, ynext)) {
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
	 * アニメーションの登録
	 **/
  private function _registAnim(eid:Int):Void {
    // 敵画像をアニメーションとして読み込む
    var name = csv.searchItem("id", '${eid}', "image");
    loadGraphic('assets/images/monster/${name}.png', true);

    // アニメーションを登録
    var speed = 6;
    animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // スライム
    animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // スライム
    animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // スライム
    animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // スライム
  }

  /**
   * アニメーションを切り替える
   **/
  private function _changeAnime():Void {
    var name = DirUtil.toString(_dir);
    animation.play(name);
  }
}
