package jp_2dgames.game;
import jp_2dgames.game.actor.Enemy;
import flixel.group.FlxTypedGroup;

/**
 * 魔法弾管理
 **/
class MagicShotMgr extends FlxTypedGroup<MagicShot> {

  /**
   * コンストラクタ
   **/
  public function new(size:Int) {
    super(size);
  }

  public static function start(px:Float, py:Float) {
    Enemy.parent.forEachAlive(function(e:Enemy) {
      MagicShot.start(px, py, e);
    });
  }
}
