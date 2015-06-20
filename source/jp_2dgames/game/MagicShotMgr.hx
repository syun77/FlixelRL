package jp_2dgames.game;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.MagicShot;
import jp_2dgames.game.item.ItemData;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
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

  /**
   * 魔法弾発射
   **/
  public static function start(px:Float, py:Float, item:ItemData) {
    Enemy.parent.forEachAlive(function(e:Enemy) {
      MagicShot.start(px, py, e, item);
    });
  }

  /**
   * 魔法弾の処理が終了したかどうか
   **/
  public static function isEnd():Bool {
    var cnt = 0;
    MagicShot.parent.forEachAlive(function(ms) {
      cnt++;
    });

    return cnt <= 0;
  }

  /**
   * 命中処理
   **/
  public static function hitTarget(target:Actor, item:ItemData):Void {
    var val = Calc.damageItem(target, item);
    if(target.damage(val)) {
      // 目標を倒した
      Message.push2(Msg.ENEMY_DEFEAT, [target.name]);
      target.kill();
      Snd.playSe("destroy", true);
      // 経験値獲得
//      addExp(_target.params.xp);
      // エフェクト再生
      Particle.start(PType.Ring, target.x, target.y, FlxColor.YELLOW);
    }
  }
}
