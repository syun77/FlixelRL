package jp_2dgames.game;

import jp_2dgames.game.gimmick.Door;
import jp_2dgames.game.gimmick.Pit;
import jp_2dgames.game.DirUtil.Dir;
import jp_2dgames.game.particle.ParticleSmoke;
import flixel.util.FlxPoint;
import jp_2dgames.lib.CsvLoader;
import flash.Lib;
import flixel.util.FlxRandom;
import flixel.FlxG;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.lib.Layer2D;

/**
 * フィールド管理
 **/
class Field {
  // グリッドサイズ
  public static inline var GRID_SIZE:Int = 32;

  // チップの種類
  public static inline var NONE:Int    = 0;  // 何もない
  public static inline var PLAYER:Int  = 1;  // プレイヤー
  public static inline var GOAL:Int    = 2;  // ゴール
  public static inline var WALL:Int    = 3;  // 壁
  public static inline var PASSAGE:Int = 4;  // 通路
  public static inline var HINT:Int    = 5;  // ヒント
  public static inline var SHOP:Int    = 6;  // お店
  public static inline var WALL2:Int   = 7;  // 壁（飛び道具は通り抜け可能）
  public static inline var SPIKE:Int   = 8;  // トゲ
  public static inline var ENEMY:Int   = 9;  // ランダム敵
  public static inline var ITEM:Int    = 10; // ランダムアイテム
  public static inline var ONEWAY_LEFT:Int  = 17; // 一方通行(左)
  public static inline var ONEWAY_UP:Int    = 18; // 一方通行(上)
  public static inline var ONEWAY_RIGHT:Int = 19; // 一方通行(右)
  public static inline var ONEWAY_DOWN:Int  = 20; // 一方通行(下)
  public static inline var BLOCK:Int        = 21; // 壊せる壁
  public static inline var DOOR3:Int        = 22; // ドア(3)
  public static inline var DOOR5:Int        = 23; // ドア(5)
  public static inline var DOOR7:Int        = 24; // ドア(7)

  // 座標変換
  public static function toWorldX(i:Float):Float {
    return i * GRID_SIZE + GRID_SIZE / 2;
  }

  public static function toWorldY(j:Float):Float {
    return j * GRID_SIZE + GRID_SIZE / 2;
  }

  public static function toChipX(x:Float):Float {
    return Math.floor((x - GRID_SIZE / 2) / GRID_SIZE);
  }

  public static function toChipY(y:Float):Float {
    return Math.floor((y - GRID_SIZE / 2) / GRID_SIZE);
  }

  // 設定したメンバ変数を消去する
  public static function clear():Void {
    _cLayer = null;
  }

  // 背景画像
  private static var _sprBack:FlxSprite;

  // コリジョンレイヤーの設定
  private static var _cLayer:Layer2D;
  public static function getLayerWidth() {
    return _cLayer.width;
  }
  public static function getLayerHeight() {
    return _cLayer.height;
  }

  public static function setCollisionLayer(layer:Layer2D):Void {
    _cLayer = layer;
  }

  // 指定した座標が壁かどうか
  public static function isWall(i:Int, j:Int):Bool {
    if(_cLayer.get(i, j) == WALL) {
      return true;
    }

    return false;
  }

  // 指定した座標が壊せるブロックかどうか
  public static function isBlock(i:Int, j:Int):Bool {
    if(_cLayer.get(i, j) == BLOCK) {
      return true;
    }

    return false;
  }

  // 指定した座標がコリジョンかどうか
  public static function isCollision(i:Int, j:Int):Bool {
    switch(_cLayer.get(i, j)) {
      case WALL:
        // コリジョン
        return true;
      case WALL2:
        // 通り抜けできない
        return true;
      case BLOCK, DOOR3, DOOR5, DOOR7:
        // 通れない
        return true;
      case -1:
        // 画面外
        return true;
      default:
        // コリジョンでない
        return false;
    }
  }

  // 指定した座標に移動できるかどうか
  public static function isMove(i:Int, j:Int, extra:String, dir:Dir):Bool {

    if(extra == "passage") {
      if(isThroughFirearm(i, j) == false) {
        // 移動できない
        return false;
      }
    }
    else {
      if(isCollision(i, j)) {
        // 移動できない
        return false;
      }

    }

    var v = _cLayer.get(i, j);
    // 一方通行チェック
    switch(v) {
      case ONEWAY_LEFT:
        if(dir == Dir.Right) {
          return false;
        }
      case ONEWAY_UP:
        if(dir == Dir.Down) {
          return false;
        }
      case ONEWAY_RIGHT:
        if(dir == Dir.Left) {
          return false;
        }
      case ONEWAY_DOWN:
        if(dir == Dir.Up) {
          return false;
        }
      default:
    }

    // 移動できる
    return true;
  }

  // 指定した座標が飛び道具が通り抜けできるかどうか
  public static function isThroughFirearm(i:Int, j:Int):Bool {
    switch(_cLayer.get(i, j)) {
      case WALL:
        // 壁は通り抜けできない
        return false;
      case BLOCK, DOOR3, DOOR5, DOOR7:
        // ブロックや扉も通れない
        return false;
      default:
        // それ以外は通過できる
        return true;
    }
  }
  // 指定の座標にあるチップを取得する
  public static function getChip(i:Int, j:Int):Int {
    var v = _cLayer.get(i, j);
    return v;
  }

  /**
   * 複数あるチップを1つに絞る
   **/
  private static function _randomNarrowOne(layer:Layer2D, v:Int) {
    var pt = layer.searchRandom(v);
    if(pt != null) {
      layer.eraseAll(v);
      layer.set(Std.int(pt.x), Std.int(pt.y), v);
      pt.put();
    }
  }

  /**
   * プレイヤーの位置や階段をランダムで配置する
   * @param layer 地形レイヤー
   * @param floor フロア数
   * @param csv Csv管理
   **/
  public static function randomize(layer:Layer2D, floor:Int, csv:Csv) {

    // 乱数を初期化
    FlxRandom.globalSeed = flash.Lib.getTimer();

    // プレイヤーを配置
    _randomNarrowOne(layer, PLAYER);
    if(layer.exists(PLAYER) == false) {
      var p = layer.searchRandom(NONE);
      layer.setFromFlxPoint(p, PLAYER);
      p.put();
    }

    // 階段を配置
    _randomNarrowOne(layer, GOAL);
    if(layer.exists(GOAL) == false) {
      var p = layer.searchRandom(NONE);
      layer.setFromFlxPoint(p, GOAL);
      p.put();
    }
    // ショップの配置
    if(FlxRandom.chanceRoll(Global.getShopAppearCount())) {
      var p = layer.searchRandom(NONE);
      layer.setFromFlxPoint(p, SHOP);
      p.put();
      // ショップ出現カウンタを初期化
      Global.resetShopAppearCount();
    }
    // 敵を配置
    {
      // 参照するデータ番号を調べる
      var id = csv.getEnemyAppearId(floor);

      // 敵の出現数
      var cnt = csv.enemy_appear.getInt(id, "cnt");
      // 敵配置
      for(i in 0...cnt) {
        var p = layer.searchRandom(NONE);
        if(p != null) {
          layer.setFromFlxPoint(p ,ENEMY);
          p.put();
        }
      }
    }

    // アイテムを配置
    {
      var id = csv.getEnemyAppearId(floor);
      var cnt = csv.enemy_appear.getInt(id, "item");
      for(i in 0...cnt) {
        var p = layer.searchRandom(NONE);
        if(p != null) {
          layer.setFromFlxPoint(p, ITEM);
          p.put();
        }
      }
    }
  }

  /**
	 * 背景画像を作成する
	 **/
  public static function createBackground(layer:Layer2D, spr:FlxSprite):FlxSprite {
    var w = layer.width * GRID_SIZE;
    var h = layer.height * GRID_SIZE;
    // チップ画像読み込み
    var chip = FlxG.bitmap.add("assets/levels/tileset.png");
    // 透明なスプライトを作成
    var col = FlxColor.SILVER;// FlxColor.TRANSPARENT;
    spr.makeGraphic(w, h, col);
    spr.pixels.fillRect(new Rectangle(0, 0, w, h), col);
    // 転送先の座標
    var pt = new Point();
    // 転送領域の作成
    var rect = new Rectangle(0, 0, GRID_SIZE, GRID_SIZE);
    // 描画関数
    var func = function(i:Int, j:Int, v:Int) {
      pt.x = i * GRID_SIZE;
      pt.y = j * GRID_SIZE;
      rect.left   = ((v - 1) % 8) * GRID_SIZE;
      rect.right  = rect.left + GRID_SIZE;
      rect.top    = Std.int((v - 1) / 8) * GRID_SIZE;
      rect.bottom = rect.top + GRID_SIZE;
      switch(v) {
        case NONE, PLAYER, PASSAGE, ENEMY, ITEM:
          // 何も描画しない
        case SPIKE:
          // トゲを配置
          Pit.start(i, j);
        case DOOR3, DOOR5, DOOR7:
          Door.start(v, i, j);
        default:
          // チップを描画する
          spr.pixels.copyPixels(chip.bitmap, rect, pt, true);
      }
    }

    // レイヤーを走査する
    layer.forEach(func);
    spr.dirty = true;
    spr.updateFrameData();

    // メンバ変数に保存
    _sprBack = spr;

    return spr;
  }

  /**
   * 指定の座標の背景を別のチップで塗りつぶす
   **/
  public static function drawBackgroundChip(chipid:Int, i:Int, j:Int):Void {
    // 背景スプライトを保持
    var spr = _sprBack;
    // チップIDを保持
    var v = chipid;

    // チップ画像読み込み
    var chip = FlxG.bitmap.add("assets/levels/tileset.png");
    // 透明なスプライトを作成
    var col = FlxColor.SILVER;// FlxColor.TRANSPARENT;
    // 転送先の座標
    var pt = new Point();
    pt.x = i * GRID_SIZE;
    pt.y = j * GRID_SIZE;
    // 転送領域の作成
    var rect = new Rectangle(0, 0, GRID_SIZE, GRID_SIZE);
    // 描画関数
    switch(chipid) {
      case GOAL, WALL, HINT, SHOP, WALL2:
        rect.left = (v - 1) * GRID_SIZE;
        rect.right = rect.left + GRID_SIZE;
        spr.pixels.copyPixels(chip.bitmap, rect, pt, true);
      case NONE:
        spr.pixels.fillRect(new Rectangle(pt.x, pt.y, GRID_SIZE, GRID_SIZE), col);
      case SPIKE:
        // トゲを配置
        Pit.start(i, j);
    }

    // レイヤーを走査する
    spr.dirty = true;
    spr.updateFrameData();
  }

  /**
   * マウス座標をチップ座標(X)で取得する
   **/
  public static function getMouseChipX():Int {
    return Std.int(Field.toChipX(FlxG.mouse.x + Field.GRID_SIZE/2));
  }

  /**
   * マウス座標をチップ座標(Y)で取得する
   **/
  public static function getMouseChipY():Int {
    return Std.int(Field.toChipY(FlxG.mouse.y + Field.GRID_SIZE/2));
  }

  /**
   * 指定したチップがある座標をランダムで返す
   **/
  public static function searchRandom(chipid:Int):FlxPoint {
    return _cLayer.searchRandom(chipid);
  }

  /**
   * 指定座標の壁を壊す
   * @return 破壊できたらtrue
   **/
  public static function breakWall(i:Int, j:Int):Bool {
    switch(_cLayer.get(i, j)) {
      case WALL, BLOCK:
      default:
        // 壁でないので壊せない
        return false;
    }

    // レイヤー情報更新
    _cLayer.set(i, j, NONE);

    // 背景画像を更新
    drawBackgroundChip(NONE, i, j);

    // 破壊エフェクト
    var px = Field.toWorldX(i);
    var py = Field.toWorldY(j);
    ParticleSmoke.start("drill", px, py);

    // 壊せた
    return true;
  }

  /**
   * 指定座標の扉を消す
   **/
  public static function eraseDoor(i:Int, j:Int):Void {
    var v = _cLayer.get(i, j);
    switch(v) {
      case DOOR3, DOOR5, DOOR7:
        _cLayer.set(i, j, NONE);
      default:
        trace('Warning: Not door (${i},${j}) = ${v}');
    }
  }
}
