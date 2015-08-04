package jp_2dgames.lib;

import flixel.util.FlxPoint;

/**
 * ノードの状態
 **/
private enum ANodeStatus {
  None;   // 初期除隊
  Open;   // オープン
  Closed; // クローズした
}

/**
 * A-starノード
 **/
class ANode {
  // ステータス
  private var _status:ANodeStatus = ANodeStatus.None;
  // 実コスト
  private var _cost:Int = 0;
  public var cost(get, never):Int;
  private function get_cost() {
    return _cost;
  }
  // ヒューリスティック・コスト
  private var _heuristic:Int = 0;
  // 親ノード
  private var _parent:ANode = null;
  // 座標
  private var _x:Int = 0; // X座標
  private var _y:Int = 0; // Y座標
  public var x(get, never):Int;
  private function get_x() {
    return _x;
  }
  public var y(get, never):Int;
  private function get_y() {
    return _y;
  }

  /**
   * コンストラクタ
   **/
  public function new(X:Int, Y:Int) {
    _x = X;
    _y = Y;
  }

  /**
   * スコアを計算する
   **/
  public function getScore():Int {
    return _cost + _heuristic;
  }

  /**
   * ヒューリスティック・コストの計算
   **/
  public function computeHeuristic(allowdiag:Bool, xgoal:Int, ygoal:Int):Void {
    if(allowdiag) {
      // 斜め移動あり
      var dx = Std.int(Math.abs(xgoal - x));
      var dy = Std.int(Math.abs(ygoal - y));
      // 大きい方をコストにする
      _heuristic = if(dx > dy) dx else dy;
    }
    else {
      // 縦横移動のみ
      var dx = Math.abs(xgoal - x);
      var dy = Math.abs(ygoal - y);
      _heuristic = Std.int(dx + dy);
    }

    // デバッグ出力
//    dump();
  }

  /**
   * ステータスがNoneかどうか
   **/
  public function isNone():Bool {
    return _status == ANodeStatus.None;
  }

  /**
   * ステータスをOpenにする
   **/
  public function open(parent:ANode, Cost:Int):Void {
//    trace('Open: (${x},${y})');
    _status = ANodeStatus.Open;
    _cost   = Cost;
    _parent = parent;
  }

  /**
   * ステータスをCloseする
   **/
  public function close():Void {
//    trace('Close: (${x},${y})');
    _status = ANodeStatus.Closed;
  }

  /**
   * パスを取得する
   **/
  public function getPath(pList:Array<FlxPoint>):Array<FlxPoint> {
    pList.push(FlxPoint.get(x, y));
    if(_parent != null) {
      // 再帰呼び出し
      _parent.getPath(pList);
    }

    return pList;
  }

  public function dump():Void {
    trace('(${x},${y}) [${_status}] cost=${_cost} heuris=${_heuristic} score=${getScore()}');
  }

  public function dumpRecursive() {
    dump();
    if(_parent != null) {
      // 再帰的にダンプする
      _parent.dumpRecursive();
    }
  }
}

/**
 * A*アルゴリズム
 **/
class AStar {

  // ■定数
  // 通過できるチップ番号
  private var CHIP_NONE:Int = 0;
  // 通過できないチップ番号
  private var CHIP_COLLISION:Int = 1;

  // 地形レイヤー
  private var _layer:Layer2D;
  // 斜め移動を許可するかどうか
  private var _allowdiag:Bool = true;
  // オープンリスト
  private var _openList:List<ANode> = null;
  // ノードインスタンス管理
  private var _pool:Map<Int,ANode> = null;
  // ゴール座標
  private var _xgoal:Int = 0;
  private var _ygoal:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new(layer:Layer2D, xgoal:Int, ygoal:Int, allowdiag:Bool=true) {
    _layer = layer;
    _allowdiag = allowdiag;
    _openList = new List<ANode>();
    _pool = new Map<Int,ANode>();
    _xgoal = xgoal;
    _ygoal = ygoal;
  }

  /**
   * ノードを生成する
   **/
  public function getNode(x:Int, y:Int):ANode {
    var idx = _layer.toIdx(x, y);
    if(_pool.exists(idx)) {
      // すでに存在しているのでプーリングから取得
      return _pool[idx];
    }

    // ないので新規作成
    var node = new ANode(x, y);
    _pool[idx] = node;
    // ヒューリスティック・コストを計算する
    node.computeHeuristic(_allowdiag, _xgoal, _ygoal);
    return node;
  }

  /**
   * ノードをオープンリストに追加する
   **/
  public function addOpneList(node:ANode):Void {
    _openList.add(node);
  }

  /**
   * ノードをオープンリストから削除する
   **/
  public function removeOpenList(node:ANode):Void {
    _openList.remove(node);
  }

  /**
   * 指定の座標にあるノードをオープンする
   **/
  public function openNode(x:Int, y:Int, cost:Int, parent:ANode):ANode {
    // 座標をチェックする
    if(_layer.check(x, y) == false) {
      // 領域外
      return null;
    }
    if(_layer.get(x, y) != CHIP_NONE) {
      // 通過できない
      return null;
    }

    // ノードを取得する
    var node = getNode(x, y);
    if(node.isNone() == false) {
      // すでにOpenしているので何もしない
      return null;
    }

    // Openする
    node.open(parent, cost);
    // Openリストに追加
    addOpneList(node);

    return node;
  }

  /**
   * 周りをOpenする
   **/
  public function openAround(parent:ANode):Void {
    var xbase = parent.x; // 基準座標(X)
    var ybase = parent.y; // 基準座標(Y)
    var cost = parent.cost; // コスト
    cost += 1; // 1歩進むので+1
    if(_allowdiag) {
      // 8方向を開く
      for(j in [-1, 0, 1]) {
        for(i in [-1, 0, 1]) {
          var x = xbase + i;
          var y = ybase + j;
          openNode(x, y, cost, parent);
        }
      }
    }
    else {
      // 4方向を開く
      var x = xbase;
      var y = ybase;
      openNode(x-1, y,   cost, parent); // 左
      openNode(x+1, y,   cost, parent); // 右
      openNode(x,   y-1, cost, parent); // 上
      openNode(x,   y+1, cost, parent); // 下
    }
  }

  /**
   * 最小スコアのノードを取得する
   **/
  public function searchMinScoreNodeFromOpenList() {
    // 最小スコア
    var min = 99999;
    // 最小実コスト
    var minCost = 99999;
    var minNode = null;
    for(node in _openList) {
      var score = node.getScore();
      if(score > min) {
        // スコアが大きい
        continue;
      }
      if(score == min && node.cost >= minCost) {
        // スコアが同じ時は実コストも比較する
        continue;
      }

      // 最小値更新
      min = score;
      minCost = node.cost;
      minNode = node;
    }

    return minNode;
  }
}
