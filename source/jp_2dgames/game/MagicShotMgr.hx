package jp_2dgames.game;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.game.gui.Message;
import jp_2dgames.game.gui.Message.Msg;
import jp_2dgames.game.actor.Actor;
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

  public static function hitTarget(target:Actor):Void {
    if(target.damage(10)) {
      // 目標を倒した
      Message.push2(Msg.ENEMY_DEFEAT, [target.name]);
      target.kill();
      FlxG.sound.play("destroy");
      // 経験値獲得
//      addExp(_target.params.xp);
      // エフェクト再生
      Particle.start(PType.Ring, target.x, target.y, FlxColor.YELLOW);
    }
  }
}
