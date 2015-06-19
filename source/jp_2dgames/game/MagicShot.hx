package jp_2dgames.game;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 敵に向かって飛んでいく魔法弾
 **/
class MagicShot extends FlxSprite {

  public static var parent:MagicShotMgr = null;

  /**
   * 生成
   **/
  public static function start(X:Float, Y:Float, target:Actor):MagicShot {
    var ms:MagicShot = parent.recycle();
    ms.init(X, Y, target);

    return ms;
  }

  // ターゲット
  private var _target:Actor;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    makeGraphic(16, 16, FlxColor.YELLOW);
    // 中心を基準に描画
    offset.set(width / 2, height / 2);
    // いったん消す
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, target:Actor):Void {
    x = X;
    y = Y;
    _target = target;
    FlxTween.tween(this, {x:_target.x}, 1, {ease:FlxEase.expoOut});
  }
}
