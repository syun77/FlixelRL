package jp_2dgames.game;

import flixel.FlxObject;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.lib.Layer2D;

/**
 * ナイトメア管理
 **/
class NightmareMgr extends FlxObject {
  public static var instance:NightmareMgr = null;

  /**
   * ナイトメア出現ターン数を取得する
   **/
  public static function getTurnLimit():Int {
    return instance._getTurnLimit();
  }
  private function _getTurnLimit():Int {
    return _csv.getInt(_lv, "turn");
  }

  /**
   * ナイトメア敵IDを取得する
   **/
  public static function getEnemyID():Int {
    return instance._getEnemyID();
  }
  private function _getEnemyID():Int {
    return _csv.getInt(_lv, "enemy_id");
  }

  // ナイトメアが存在しているかどうか
  private var _exists:Bool;
  // ナイトメア出現テーブル
  private var _csv:CsvLoader;
  // ナイトメアレベル
  private var _lv:Int;

  /**
   * コンストラクタ
   **/
  public function new(csv:CsvLoader) {
    super();
    _exists = false;
    _csv    = csv;
    _lv     = 1;
  }

  /**
   * 次のターンに進む
   **/
  public function nextTurn(layer:Layer2D):Void {
    var v = Global.getTurnLimitNightmare();
    // ターン数を減らす
    v -= 1;
    if(v <= 0) {
      v = 0;
      if(_exists == false) {
        var pt = _searchNightmarePosition(layer);
        if(pt != null) {
          // ナイトメア出現
          var px = Std.int(pt.x);
          var py = Std.int(pt.y);
          pt.put();
          Enemy.add(_getEnemyID(), px, py);
          _exists = true;
        }
      }
    }
    Global.setTurnLimitNightmare(v);
  }

  /**
   * ナイトメアが存在するかどうか
   **/
  private function _existsNightmare():Bool {
    var ret = false;

    Enemy.parent.forEachAlive(function(e:Enemy) {
      if(e.id == _getEnemyID()) {
        ret = true;
      }
    });

    return ret;
  }

  /**
   * ナイトメアを出現させる
   **/
  private function _searchNightmarePosition(layer:Layer2D):FlxPoint {

    var player = cast(FlxG.state, PlayState).player;

    // まずはプレイヤーが登場した位置に出現できるかどうかを調べる
    {
      var pt = layer.search(Field.PLAYER);
      var px = Std.int(pt.x);
      var py = Std.int(pt.y);
      if(player.existsPosition(px, py) == false) {
        if(Enemy.getFromPosition(px, py) == null) {
          // 生成可能
          return pt;
        }
      }
    }

    // チャレンジ回数
    var cnt = 10;
    for(i in 0...cnt) {
      var pt = layer.searchRandom(Field.ENEMY);
      if(pt == null) {
        break;
      }
      var px = Std.int(pt.x);
      var py = Std.int(pt.y);

      if(player.existsPosition(px, py)) {
        // 生成できないのでやり直す
        continue;
      }
      if(Enemy.getFromPosition(px, py) != null) {
        // 生成できないのでやり直す
        continue;
      }

      // 生成可能
      return pt;
    }

    // 出現できない
    return null;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }
}
