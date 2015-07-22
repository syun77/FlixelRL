package jp_2dgames.game.event;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.game.util.DirUtil;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

// 状態
private enum State {
  Standby; // 待機中
  Walk;    // 移動中
}

/**
 * イベントキャラ
 **/
class EventNpc extends FlxSprite {

  // 管理クラス
  public static var parent:FlxTypedGroup<EventNpc> = null;
  // コリジョンチェック
  public static var isCollision:Int->Int->Bool;

  // 追加
  public static function add(type:String, xc:Int, yc:Int, dir:Dir):Int {
    var npc:EventNpc = parent.recycle();
    npc.init(type, xc, yc, dir);
    return npc.ID;
  }
  // 指定のIDを持つオブジェクトを取得
  public static function get(ID:Int):EventNpc {
    var npc:EventNpc = null;
    parent.forEachAlive(function(npc2:EventNpc) {
      if(npc2.ID == ID) {
        npc = npc2;
      }
    });
    return npc;
  }
  public static function forEach(ID:Int, func:EventNpc->Void):Void {
    parent.forEachAlive(function(npc:EventNpc) {
      if(npc.ID == ID) {
        func(npc);
      }
    });
  }

  /**
   * 指定の座標に移動可能かどうか
   **/
  public static function isMove(xc:Int, yc:Int):Bool {
    if(isCollision(xc, yc)) {
      // 壁があるので移動できない
      return false;
    }
    var bHit = false;
    parent.forEachAlive(function(npc:EventNpc) {
      if(npc.existsPosition(xc, yc)) {
        bHit = true;
      }
    });
    if(bHit) {
      // 他のNPCがいる
      return false;
    }

    // 移動可能
    return true;
  }

  // 種別
  private var _type:String = "";
  // チップ座標
  private var _xprev:Float = 0;
  private var _yprev:Float = 0;
  private var _xnext:Float = 0;
  private var _ynext:Float = 0;
  // 方向
  private var _dir:Dir = Dir.Down;
  // 状態
  private var _state:State = State.Standby;
  // 歩きタイマー
  private var _tWalk:Int = 0;
  // ランダム歩きフラグ
  private var _bRandomWalk:Bool = false;
  // ランダム歩きタイマー
  private var _tRandomWalk:Float = 0;

  // プロパティ
  // チップ座標(X)
  public var xchip(get, never):Int;
  private function get_xchip() {
    return Std.int(_xnext);
  }
  // チップ座標(Y)
  public var ychip(get, never):Int;
  private function get_ychip() {
    return Std.int(_ynext);
  }
  // 方向
  public var dir(get, never):Dir;
  private function get_dir() {
    return _dir;
  }

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    kill();
  }

  /**
   * 初期化
   **/
  public function init(type:String, xc:Int, yc:Int, dir:Dir):Void {
    _xprev = xc;
    _yprev = yc;
    _xnext = xc;
    _ynext = yc;
    _type  = type;
    _dir   = dir;
    x = Field.toWorldX(xc);
    y = Field.toWorldY(yc);
    _bRandomWalk = false;
    color = FlxColor.WHITE;
    alpha = 1;

    var res = "";
    switch(type) {
      case "player": res = "assets/images/player.png";
      case "cat":    res = "assets/images/cat.png";
    }

    // リソース読み込み
    loadGraphic(res, true);

    // 中心を基準に描画する
    offset.set(width / 2, height / 2);

    // アニメーション設定
    _registAnim(type);

    // アニメーション再生
    _changeAnim(true);

//    FlxG.watch.add(this, "_state");
//    FlxG.debugger.visible = true;
  }

  /**
   * 指定の座標に存在するかどうか
   **/
  public function existsPosition(xc:Int, yc:Int):Bool {
    if(xc == xchip && yc == ychip) {
      return true;
    }
    return false;
  }

  /**
   * 待機状態かどうか
   **/
  public function isStandby():Bool {
    return _state == State.Standby;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Standby:
        _updateStandby();
      case State.Walk:
        if(_updateWalk()) {
          // 移動完了
          _state = State.Standby;
        }
    }
  }

  /**
   * 更新・待機
   **/
  private function _updateStandby():Void {
    if(_bRandomWalk) {
      // ランダム歩き有効
      _tRandomWalk -= FlxG.elapsed;
      if(_tRandomWalk < 0) {
        // ランダムな方向に歩く
        requestWalk(DirUtil.random());
        // タイマー初期化
        _tRandomWalk = FlxRandom.floatRanged(3, 7);
      }
    }
  }

  /**
   * 更新・歩き
   **/
  private function _updateWalk():Bool {
    var tWait:Int = 24;
    _tWalk++;
    var t = _tWalk / tWait;
    // 移動方向を求める
    var dx = _xnext - _xprev;
    var dy = _ynext - _yprev;
    // 座標を線形補完する
    x = Field.toWorldX(_xprev) + (dx * Field.GRID_SIZE) * t;
    y = Field.toWorldX(_yprev) + (dy * Field.GRID_SIZE) * t;
    if(_tWalk >= tWait) {
      // 移動完了
      _xprev = _xnext;
      _yprev = _ynext;
      if(_type == "player") {
        // 待機アニメに戻る
        _changeAnim(false);
      }
      return true;
    }
    else {
      // 移動中
      return false;
    }
  }

  /**
   * アニメーションを登録
   **/
  private function _registAnim(type):Void {
    switch(type) {
      case "player":
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
      default:
        // アニメーションを登録
        var speed = 6;
        animation.add(DirUtil.toString(Dir.Left),  [0, 1, 2, 1], speed); // 左
        animation.add(DirUtil.toString(Dir.Up),    [3, 4, 5, 4], speed); // 上
        animation.add(DirUtil.toString(Dir.Right), [6, 7, 8, 7], speed); // 右
        animation.add(DirUtil.toString(Dir.Down),  [9, 10, 11, 10], speed); // 下
    }
  }

  // アニメーション名を取得する
  private function getAnimName(bStop:Bool, dir:Dir):String {
    if(_type == "player") {
      var pre = bStop ? "stop" : "walk";
      var suf = DirUtil.toString(dir);

      return pre + "-" + suf;
    }
    else {
      return DirUtil.toString(_dir);
    }

  }

  // アニメ変更
  private function _changeAnim(bStop:Bool):Void {
    animation.play(getAnimName(bStop, dir));
  }

  // 指定方向を向く
  public function requestDir(dir:Dir):Bool {
    if(_state != State.Standby) {
      // 振り向けない
      return false;
    }
    // 向きを反映
    _dir = dir;
    _changeAnim(true);

    return true;
  }

  // 歩き要求
  public function requestWalk(dir:Dir):Bool {
    if(_state != State.Standby) {
      // 歩けない
      return false;
    }

    // 向きを反映
    _dir = dir;

    var pt = FlxPoint.get();
    DirUtil.move(dir, pt);

    var xnext = Std.int(_xprev + pt.x);
    var ynext = Std.int(_yprev + pt.y);
    pt.put();
    // 移動可能かどうかをチェックする
    if(isMove(xnext, ynext) == false) {
      // 移動できない
      return false;
    }

    // 移動可能
    _xnext = xnext;
    _ynext = ynext;

    _state = State.Walk;
    _tWalk = 0;
    _changeAnim(false);

    // 歩き要求成功
    return true;
  }

  // ランダム歩きフラグを設定する
  public function requestRandomWalk(b:Bool):Void {
    _bRandomWalk = b;
    _tRandomWalk = FlxRandom.floatRanged(2, 8);
  }
}
