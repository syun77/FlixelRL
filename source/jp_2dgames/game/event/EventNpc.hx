package jp_2dgames.game.event;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.game.util.DirUtil;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * NPCコマンド
 **/
private class _Cmd {
  public static inline var TYPE_MOVE:Int    = 0;  // 移動する
  public static inline var TYPE_DIR:Int     = 1;  // 向きを変える
  public static inline var TYPE_WAIT:Int    = 2;  // 一時停止する
  public static inline var TYPE_DESTROY:Int = 99; // 消滅する

  public var type:Int = 0;         // コマンド種別
  public var dir:Dir  = Dir.None;  // 方向
  public var params:Array<Int>;    // 汎用パラメータ
  public var paramStr:String = ""; // 汎用パラメータ
  public var paramFloat:Float = 0; // 汎用パラメータ

  public function new() {
    params = new Array<Int>();
  }
}


// 状態
private enum State {
  Standby; // 待機中
  Walk;    // 移動中
  Wait;    // 実行停止中
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
  // MOVEコマンドによる移動先
  private var _xtarget:Int = 0;
  private var _ytarget:Int = 0;
  private var _bRequstMove:Bool = false;

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
  // コマンドキュー
  private var _cmdQueue:List<_Cmd>;

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
    _bRequstMove = false;
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

    // コマンドキュー作成
    _cmdQueue = new List<_Cmd>();

//    FlxG.watch.add(this, "_state");
//    FlxG.watch.add(this, "xchip");
//    FlxG.watch.add(this, "ychip");
//    FlxG.watch.add(this, "_xtarget");
//    FlxG.watch.add(this, "_ytarget");
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

  private function _checkRequestMove():Bool {
    if(_bRequstMove == false) {
      // 移動完了
      return false;
    }

    if(existsPosition(_xtarget, _ytarget)) {
      // 移動完了
      _bRequstMove = false;
      return false;
    }
    // まだ歩く
    if(requestWalk(dir) == false) {
      // 移動できなかった
      _bRequstMove = false;
      return false;
    }

    // 歩く
    return true;
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
          // まだ歩くかどうかチェック
          _checkRequestMove();
        }
      case State.Wait:
        // 何もしない
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

    if(_cmdQueue.length > 0) {
      // キューを処理する
      var cmd = _cmdQueue.pop();
      switch(cmd.type) {
        case _Cmd.TYPE_WAIT:
          _execWait(cmd);
        case _Cmd.TYPE_MOVE:
          _execMove(cmd);
        case _Cmd.TYPE_DIR:
          _execDir(cmd);
        case _Cmd.TYPE_DESTROY:
          _execKill(cmd);
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
        _changeAnim(true);
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

  // 一時停止
  public function requestWait(time:Float):Void {

    var cmd = new _Cmd();
    cmd.type = _Cmd.TYPE_WAIT;
    cmd.paramFloat = time;
    _cmdQueue.add(cmd);
  }
  private function _execWait(cmd:_Cmd):Void {

    _state = State.Wait;
    new FlxTimer(cmd.paramFloat, function(t:FlxTimer) {
      _state = State.Standby;
    });
  }

  // 指定方向を向く
  public function requestDir(dir:Dir):Void {

    var cmd = new _Cmd();
    cmd.type = _Cmd.TYPE_DIR;
    cmd.dir  = dir;
    _cmdQueue.add(cmd);
  }
  public function _execDir(cmd:_Cmd):Bool {
    if(_state != State.Standby) {
      // 振り向けない
      return false;
    }

    _dir = cmd.dir;
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

  // 指定した方向に歩く
  public function requestMove(dir:Dir, cnt:Int):Void {

    var cmd = new _Cmd();
    cmd.type = _Cmd.TYPE_MOVE;
    cmd.dir  = dir;
    cmd.params.push(cnt);
    _cmdQueue.add(cmd);
  }
  private function _execMove(cmd:_Cmd):Bool {
    if(_state != State.Standby) {
      return false;
    }

    _dir = cmd.dir;
    var cnt = cmd.params[0];

    // 移動先を求める
    var pt = FlxPoint.get();
    for(i in 0...cnt) {
      pt = DirUtil.move(dir, pt);
    }
    _xtarget = Std.int(pt.x) + xchip;
    _ytarget = Std.int(pt.y) + ychip;
    pt.put();

    if(requestWalk(dir) == false) {
      // 移動できない
      return false;
    }

    // 移動要求開始
    _bRequstMove = true;

    return true;
  }

  public function requestKill(type:String, time:Float):Void {
    var cmd = new _Cmd();
    cmd.type = _Cmd.TYPE_DESTROY;
    cmd.paramStr = type;
    cmd.paramFloat = time;

    _cmdQueue.add(cmd);
  }
  private function _execKill(cmd:_Cmd):Bool {
    switch(cmd.paramStr) {
      case "fade":
        FlxTween.tween(this, {alpha:0}, cmd.paramFloat, {complete:function(tween:FlxTween) {
          kill();
        }});
      default:
        kill();
    }

    return true;
  }
}