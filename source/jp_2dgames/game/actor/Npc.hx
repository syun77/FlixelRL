package jp_2dgames.game.actor;
import flixel.util.FlxRandom;
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

  // 停止タイマー
  private var _tWait:Float = 0;
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

    FlxG.watch.add(this, "_state");
    FlxG.watch.add(this, "_tWait");

    FlxG.debugger.visible = true;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case Actor.State.KeyInput:
        _tWait -= FlxG.elapsed;
        if(_tWait <= 0) {
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
            _change(Actor.State.Move);
          }
          else {
            // 移動できない
            _change(Actor.State.TurnEnd);
          }
        }
      case Actor.State.Move:
        if(_updateWalk()) {
          // 移動完了
          _change(Actor.State.TurnEnd);
        }
      case Actor.State.TurnEnd:
        _tWait = FlxRandom.floatRanged(5, 10);
        _tWait = 3;
        _change(Actor.State.KeyInput);

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

    if(Enemy.target.existsPosition(xnext, ynext)) {
      // プレイヤーがいるので移動できない
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
