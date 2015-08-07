package jp_2dgames.game;

import jp_2dgames.game.util.Calc;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.lib.AStar;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.particle.ParticleSmoke;
import flixel.addons.effects.FlxWaveSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.gimmick.Door;
import jp_2dgames.game.gimmick.Pit;
import jp_2dgames.game.util.DirUtil.Dir;
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
  public static inline var CAT:Int     = 11; // ネコ
  public static inline var HEART_RED:Int    = 13; // ハート(赤)
  public static inline var HEART_BLUE:Int   = 14; // ハート(青)
  public static inline var HEART_GREEN:Int  = 15; // ハート(緑)
  public static inline var HEART_YELLOW:Int = 16; // ハート(黄)
  public static inline var ONEWAY_LEFT:Int  = 17; // 一方通行(左)
  public static inline var ONEWAY_UP:Int    = 18; // 一方通行(上)
  public static inline var ONEWAY_RIGHT:Int = 19; // 一方通行(右)
  public static inline var ONEWAY_DOWN:Int  = 20; // 一方通行(下)
  public static inline var BLOCK:Int        = 21; // 壊せる壁
  public static inline var DOOR3:Int        = 22; // ドア(3)
  public static inline var DOOR5:Int        = 23; // ドア(5)
  public static inline var DOOR7:Int        = 24; // ドア(7)

  private static inline var NIGHTMARE_COLOR = 0xA0A0A0;

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
    _sprBack = null;
    _sprWave = null;
  }

  // 背景画像
  private static var _sprBack:FlxSprite;
  // ゆらゆらエフェクト
  private static var _sprWave:FlxWaveSprite;
  // Tweenエフェクト
  private static var _tweenColor:FlxTween = null;
  private static var _tweenWave:FlxTween = null;

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
    if(layer.exists(SHOP) == false) {
      // ショップがなければ生成チェック
      if(FlxRandom.chanceRoll(Global.getShopAppearCount())) {
        var p = layer.searchRandom(NONE);
        layer.setFromFlxPoint(p, SHOP);
        p.put();
        // ショップ出現カウンタを初期化
        Global.resetShopAppearCount();
      }
    }
    // 敵を配置
    if(Global.isMapExtra() == false)
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
      if(Global.isEscapeFromNightmare()) {
        // ナイトメアからの逃走ボーナス
        cnt += 3;
        // 逃走フラグを下げておく
        Global.setEscapeFromNightmare(false);
      }
      for(i in 0...cnt) {
        var p = layer.searchRandom(NONE);
        if(p != null) {
          layer.setFromFlxPoint(p, ITEM);
          p.put();
        }
      }
    }

    // 回復チップ配置
    if(Global.getFloor() > 4) {
      if(FlxRandom.chanceRoll(20)) {
        var p = layer.searchRandom(NONE);
        if(p != null) {
          if(FlxRandom.chanceRoll(70)) {
            // 体力回復
            layer.setFromFlxPoint(p, HEART_RED);
          }
          else {
            // 満腹度回復
            layer.setFromFlxPoint(p, HEART_BLUE);
          }
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
    var none = FlxG.bitmap.add("assets/levels/tilenone.png");
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

      // 床チップ描画
      {
        rect.left   = 0;
        rect.right  = rect.left + GRID_SIZE;
        rect.top    = 0;
        rect.bottom = rect.top + GRID_SIZE;
        spr.pixels.copyPixels(none.bitmap, rect, pt, false);
      }

      rect.left   = ((v - 1) % 8) * GRID_SIZE;
      rect.right  = rect.left + GRID_SIZE;
      rect.top    = Std.int((v - 1) / 8) * GRID_SIZE;
      rect.bottom = rect.top + GRID_SIZE;

      // 床チップ描画
      switch(v) {
        case NONE, PLAYER, PASSAGE, ENEMY, ITEM, CAT:
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
   * Waveスプライトを登録する
   **/
  public static function setWaveSprite(spr:FlxWaveSprite):Void {
    _sprWave = spr;
  }

  /**
   * 背景を暗くする
   **/
  public static function startFadeBackground():Void {
    _tweenColor = FlxTween.color(_sprWave, 5, FlxColor.WHITE, NIGHTMARE_COLOR, 1, 1, {ease:FlxEase.sineOut, complete:function(tween:FlxTween) {
      _tweenColor = null; // 完了したら参照を消す
    }});
    _tweenWave = FlxTween.tween(_sprWave, {strength:3, speed:5}, 10, {ease:FlxEase.sineOut, complete:function(tween:FlxTween) {
      _tweenWave = null; // 完了したら参照を消す
    }});
  }
  public static function resetFadeBackGround():Void {
    if(_tweenColor != null) {
      // 完了していなければ消す
      _tweenColor.cancel();
      _tweenColor = null;
    }
    if(_tweenWave != null) {
      // 完了していなければ消す
      _tweenWave.cancel();
      _tweenWave = null;
    }

    FlxTween.color(_sprWave, 0.3, NIGHTMARE_COLOR, FlxColor.WHITE, 1, 1, {ease:FlxEase.sineOut});
    FlxTween.tween(_sprWave, {strength:0, speed:0}, 0.3, {ease:FlxEase.sineOut});
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
    // 床スプライトを作成
    var none = FlxG.bitmap.add("assets/levels/tilenone.png");

    // 転送先の座標
    var pt = new Point();
    pt.x = i * GRID_SIZE;
    pt.y = j * GRID_SIZE;
    // 転送領域の作成
    var rect = new Rectangle(0, 0, GRID_SIZE, GRID_SIZE);
    // 床で塗りつぶす
    {
      rect.left   = 0;
      rect.right  = rect.left + GRID_SIZE;
      rect.top    = 0;
      rect.bottom = rect.top + GRID_SIZE;
      spr.pixels.copyPixels(none.bitmap, rect, pt, false);
    }
    // 描画関数
    switch(chipid) {
      case GOAL, WALL, HINT, SHOP, WALL2:
        rect.left   = ((v - 1) % 8) * GRID_SIZE;
        rect.right  = rect.left + GRID_SIZE;
        rect.top    = Std.int((v - 1) / 8) * GRID_SIZE;
        rect.bottom = rect.top + GRID_SIZE;
        spr.pixels.copyPixels(chip.bitmap, rect, pt, true);
      case NONE:
        // 何も描画しない
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
   * 指定座標のピットを破壊する
   * @return 破壊できたらtrue
   **/
  public static function breakPit(i:Int, j:Int, bKill:Bool=false):Bool {
    if(_cLayer.get(i, j) != SPIKE) {
      // ピットでないので何もしない
      return false;
    }

    // レイヤー情報更新
    _cLayer.set(i, j, NONE);

    if(bKill) {
      // インスタンスも消す
      Pit.parent.forEachAlive(function(p:Pit) {
        if(p.xchip == i && p.ychip == j) {
          // 消す
          p.kill();
        }
      });
    }

    return true;
  }

  /**
   * 一方通行を消す
   * @return 破壊できたらtrue
   **/
  public static function breakOneWay(i:Int, j:Int):Bool {
    switch(_cLayer.get(i, j)) {
      case ONEWAY_LEFT, ONEWAY_UP, ONEWAY_RIGHT, ONEWAY_DOWN:
      default:
        // 何もしない
        return false;
    }

    // レイヤー情報更新
    _cLayer.set(i, j, NONE);

    // 背景画像を更新
    drawBackgroundChip(NONE, i, j);

    // エフェクト再生
    var px = toWorldX(i);
    var py = toWorldY(j);
    Particle.start(PType.Ring2, px, py, FlxColor.PINK);

    Snd.playSe("break", true);

    return true;
  }

  /**
   * 水たまりを消す
   * @return 消すことができたらtrue
   **/
  public static function breakWall2(i:Int, j:Int):Bool {
    switch(_cLayer.get(i, j)) {
      case WALL2:
      default:
        // 何もしない
        return false;
    }

    // レイヤー情報更新
    _cLayer.set(i, j, NONE);

    // 背景画像を更新
    drawBackgroundChip(NONE, i, j);

    // エフェクト再生
    var px = toWorldX(i);
    var py = toWorldY(j);
    Particle.start(PType.Ring2, px, py, FlxColor.AQUAMARINE);

    Snd.playSe("break", true);

    return true;
  }

  /**
   * ハートを消す
   * @return 消すことができたらtrue
   **/
  public static function breakHeart(actor:Actor, i:Int, j:Int):Bool {
    var chip = _cLayer.get(i, j);
    switch(chip) {
      case HEART_RED:
        // 体力回復
        var val = Calc.getHeartRecoveryRatio();
        // 回復実行して回復した値を取得する
        val = actor.addHp2(val);
        Message.push2(Msg.RECOVER_HP, [actor.name, val]);
        FlxG.sound.play("recover");
      case HEART_BLUE:
        // 満腹度回復
        var val = Calc.getHeartRecoveryRatio();
        actor.addFood2(val);
        if(actor.isFoodMax()) {
          // 満腹になった
          Message.push2(Msg.RECOVER_FOOD_MAX);
        }
        else {
          Message.push2(Msg.RECOVER_FOOD);
        }
        FlxG.sound.play("recover");
      case HEART_GREEN:
      case HEART_YELLOW:
      default:
        // 何もしない
        return false;
    }

    // レイヤー情報更新
    _cLayer.set(i, j, NONE);

    // 背景画像を更新
    drawBackgroundChip(NONE, i, j);

    // エフェクト再生
    var px = toWorldX(i);
    var py = toWorldY(j);
    Particle.start(PType.Ring2, px, py, FlxColor.AQUAMARINE);

    Snd.playSe("break", true);

    return true;
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

    // 破壊SE
    Snd.playSe("break", true);

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

  /**
   * 移動可能なフィールドの情報を計算してLayer2Dとして取得する
   **/
  private static function _computeMap():Layer2D {

    var layer = new Layer2D(_cLayer.width, _cLayer.height);

    _cLayer.forEach(function(i:Int, j:Int, v:Int) {
      if(isCollision(i, j)) {
        layer.set(i, j, 1);
      }
    });

    return layer;
  }

  /**
   * A*による経路探索
   **/
  public static function findPath(xstart:Int, ystart:Int, xgoal:Int, ygoal:Int):Array<FlxPoint> {

    // A*計算オブジェクト生成
    var astar = new AStar(_computeMap(), xgoal, ygoal, false);
    // スタート地点のノード作成
    // スタート地点なのでコストは0
    var node = astar.openNode(xstart, ystart, 0, null);
    if(node == null) {
      // スタート地点が不正
      return null;
    }
    astar.addOpenList(node);

    // 試行回数。1000回超えたら強制中断
    var cnt = 0;
    while(cnt < 1000) {
      astar.removeOpenList(node);
      // 周囲を開く
      astar.openAround(node);
      // 最小スコアのノードを探す
      node = astar.searchMinScoreNodeFromOpenList();
      if(node == null) {
        // 袋小路なのでおしまい
        return null;
      }
      if(node.x == xgoal && node.y == ygoal) {
        // ゴールにたどり着いた
        astar.removeOpenList(node);
//        node.dumpRecursive();
        // パスを取得する
        var pList = node.getPath(new Array<FlxPoint>());
        // 反転する
        pList.reverse();
        return pList;
      }
    }

    return null;
  }

  /**
   * 階段からエフェクトを生成する
   **/
  public static function startStairEffect():Void {
    var pt = _cLayer.search(GOAL);
    if(pt == null) {
      return;
    }
    var px = toWorldX(pt.x);
    var py = toWorldY(pt.y);
    Particle.start(PType.Ring2, px, py, FlxColor.YELLOW);
    pt.put();
  }
}
