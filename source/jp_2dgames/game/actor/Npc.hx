package jp_2dgames.game.actor;
import jp_2dgames.game.item.ItemData.ItemExtraParam;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Inventory;
import jp_2dgames.game.item.ItemConst;
import flixel.util.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxColor;
import jp_2dgames.game.util.DirUtil;
import flixel.group.FlxTypedGroup;

/**
 * NPCクラス
 **/
class Npc extends Actor {

  // NPC種別
  public static inline var TYPE_RED:Int   = 1; // 赤いネコ
  public static inline var TYPE_BLUE:Int  = 2; // 青いネコ
  public static inline var TYPE_WHITE:Int = 3; // 白いネコ
  public static inline var TYPE_GREEN:Int = 4; // 緑のネコ

  // 管理クラス
  public static var parent:FlxTypedGroup<Npc> = null;

  /**
   * NPCを生成する
   **/
  public static function add(type:Int, xchip:Int, ychip:Int):Npc {
    var npc:Npc = parent.recycle();

    var params = new Params();
    params.id = type;
    npc.init(xchip, ychip, DirUtil.random(), params, true);

    return npc;
  }

  /**
   * 種別に対応するアイテムIDを取得する
   **/
  public static function typeToItemID(type:Int):Int {
    switch(type) {
      case TYPE_RED:   return ItemConst.ORB1;
      case TYPE_BLUE:  return ItemConst.ORB2;
      case TYPE_WHITE: return ItemConst.ORB3;
      case TYPE_GREEN: return ItemConst.ORB4;
      default:
        trace('Warning: Invalid type:${type}');
        return ItemConst.FOOD1;
    }
  }
  public static function typeToValue(type:Int):Int {
    switch(type) {
      case TYPE_RED:   return 0;
      case TYPE_BLUE:  return 1;
      case TYPE_WHITE: return 2;
      case TYPE_GREEN: return 3;
      default:
        trace('Warning: Invalid type:${type}');
        return 0;
    }
  }

  /**
   * NPC種別を取得する
   **/
  public function getType():Int {
    return _id;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // ネコ画像読み込み
    loadGraphic("assets/images/cat.png", true);

    // アニメーションを登録
    var speed = 6;
    animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // 左
    animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // 上
    animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // 右
    animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // 下

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    super.kill();
  }

  /**
   * 初期化
   **/
  override public function init(X:Int, Y:Int, dir:Dir, params:Params, bCreate:Bool = false):Void {

    // ID取得
    _id = params.id;

    switch(_id) {
      case TYPE_RED:
        color = FlxColor.SALMON;
      case TYPE_BLUE:
        color = 0x80A0FF;
      case TYPE_WHITE:
        color = FlxColor.WHITE;
      case TYPE_GREEN:
        color = FlxColor.LIME;
    }

    // アニメーション設定
    _changeAnime();

    super.init(X, Y, dir, params);

//    FlxG.watch.add(this, "_state");
  }

  /**
   * 移動要求
   **/
  public function requestMove():Void {
    // 移動開始
    // ランダムな方向
    _dir = DirUtil.random();
    _changeAnime();

    var pt = FlxPoint.get(_xprev, _yprev);
    pt = DirUtil.move(_dir, pt);
    var xnext = Std.int(pt.x);
    var ynext = Std.int(pt.y);
    if(_isMove(xnext, ynext)) {
      // 移動する
      _xnext = xnext;
      _ynext = ynext;
      _tMove = 0;
      _change(Actor.State.MoveBegin);
    }
    else {
      // 移動できない
      _change(Actor.State.TurnEnd);
    }
  }

  /**
   * オーブ獲得
   **/
  public function getOrb():Bool {
    var itemid = typeToItemID(_id);
    var param = new ItemExtraParam();
    param.value = typeToValue(_id);

    // オーブに変化したかどうか
    var bOrb = true;
    if(Inventory.isFull()) {
      // アイテムが一杯なので地面に置く
      var pt = FlxPoint.get();
      if(DropItem.checkDrop(pt, xchip, ychip)) {
        // 置ける
        DropItem.add(Std.int(pt.x), Std.int(pt.y), itemid, param);
      }
      else {
        // 置けない
        bOrb = false;
      }
    }
    else {
      // オーブ獲得
      Inventory.instance.addItem(itemid, param);
    }

    return bOrb;
  }

  /**
   * 更新
   **/
  override public function proc():Void {
    super.proc();

    switch(_state) {
      case Actor.State.Move:
        if(_updateWalk()) {
          // 移動完了
          _change(Actor.State.TurnEnd);
        }
      default:
    }
  }

  /**
   * 指定の座標へ移動が可能かどうか
   **/
  private function _isMove(xnext:Int, ynext:Int):Bool {
    var bHit:Bool = false;
    Enemy.parent.forEachAlive(function(e:Enemy) {
      if(xnext == e.xchip && ynext == e.ychip) {
        // 移動先に敵がいる
        bHit = true;
      }
    });
    if(bHit) {
      // 敵がいるので移動できない
      return false;
    }

    if(Field.isMove(xnext, ynext, "", _dir) == false) {
      // 壁があるので移動できない
      return false;
    }

    var player = Enemy.target;
    if(player.existsPosition(xnext, ynext)) {
      // プレイヤーがいるので移動できない
      return false;
    }

    var dx = player.xchip - xchip;
    var dy = player.ychip - ychip;
    if(Math.abs(dx) + Math.abs(dy) < 2) {
      // プレイヤーが近くにいるときも動けない
      return false;
    }

    // 移動可能
    return true;
  }

  /**
   * アニメーションを切り替える
   **/
  private function _changeAnime():Void {
    var name = DirUtil.toString(_dir);
    animation.play(name);
  }
}
