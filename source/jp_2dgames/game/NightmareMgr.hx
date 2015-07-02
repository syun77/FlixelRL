package jp_2dgames.game;

/**
 * ナイトメア管理
 **/
import jp_2dgames.game.actor.EnemyConst;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.lib.Layer2D;
class NightmareMgr {
  // ゲーム開始時の残りターン数
  public static inline var TURN_LIMIT_FIRST:Int = 120;

  public static var instance:NightmareMgr = null;

  private var _exists:Bool;
  /**
   * コンストラクタ
   **/
  public function new() {
    _exists = false;
  }

  /**
   * 次のターンに進む
   **/
  public function nextTurn(layer:Layer2D):Void {
    var v = Global.getTurnLimitNightmare();
    // ターン数を減らす
    v -= 1;
    if(v < 0) {
      v = 0;
      if(_exists == false) {
        var pt = _searchNightmarePosition(layer);
        if(pt != null) {
          // ナイトメア出現
          var px = Std.int(pt.x);
          var py = Std.int(pt.y);
          pt.put();
          Enemy.add(EnemyConst.NIGHTMARE, px, py);
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
      if(e.id == EnemyConst.NIGHTMARE) {
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
      if(player.checkPosition(px, py)) {
        // 生成可能
        return pt;
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

      if(player.checkPosition(px, py)) {
        // 生成できないのでやり直す
        continue;
      }
      if(Enemy.getFromPositino(px, py) != null) {
        // 生成できないのでやり直す
        continue;
      }

      // 生成可能
      return pt;
    }

    // 出現できない
    return null;
  }
}
