package jp_2dgames.game;
import jp_2dgames.game.util.Calc;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
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
   * 敵全体に魔法弾発射
   **/
  public static function startAllEnemy(px:Float, py:Float, item:ItemData) {
    var player = cast(FlxG.state, PlayState).player;
    var cnt = 0;
    Enemy.parent.forEachAlive(function(e:Enemy) {
      MagicShot.start(px, py, player, e, item);
      cnt++;
    });

    if(cnt > 0) {
      // 発射SE
      Snd.playSe("flash");
    }
    else {
      // 敵がいないので何も起こらない
      Message.push2(Msg.NOTHING_HAPPENED);
      Snd.playSe("error");
    }
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
    var val    = Calc.damageItem(target, item, null);
    var extra  = ItemUtil.getExtra(item.id);
    var extval = ItemUtil.getExtVal(item.id);
    if(target.damage(val)) {
      // 目標を倒した
      Message.push2(Msg.ENEMY_DEFEAT, [target.name]);
      target.kill();
      Snd.playSe("destroy", true);
      // 経験値獲得
      ExpMgr.add(target.params.xp);
      // エフェクト再生
      Particle.start(PType.Ring, target.x, target.y, FlxColor.YELLOW);
    }
    else if(extra != "") {
      // 特殊効果あり
      ItemUtil.useExtra(target, extra, extval, null);
    }
  }
}
