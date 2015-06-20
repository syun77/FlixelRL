package jp_2dgames.game;
import jp_2dgames.game.item.ItemData;
import flash.display.BlendMode;
import flixel.util.FlxAngle;
import flixel.util.FlxRandom;
import jp_2dgames.game.actor.Actor;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * 敵に向かって飛んでいく魔法弾
 **/
class MagicShot extends FlxSprite {

  // 親
  public static var parent:MagicShotMgr = null;

  /**
   * 生成
   * @param X 開始座標(X)
   * @param Y 開始座標(Y)
   * @param target 攻撃対象
   * @param item アイテム情報
   **/
  public static function start(X:Float, Y:Float, target:Actor, item:ItemData):MagicShot {
    var ms:MagicShot = parent.recycle();
    ms.init(X, Y, target, item);

    return ms;
  }

  // 最大移動速度
  public static inline var SPEED_MAX:Float = 1200;
  // 最大旋回速度
  public static inline var ROT_SPEED_MAX:Float = 45;

  // ターゲット
  private var _target:Actor;
  // アイテム情報
  private var _item:ItemData;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    loadGraphic("assets/images/effect.png", true);

    // アニメーション登録
    animation.add('play', [0], 1);

    animation.play('play');

    // スケール値設定
    scale.set(0.5, 0.5);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    // 加算ブレンド
    blend = BlendMode.ADD;
    // 色を変える
    color = FlxColor.YELLOW;

    // いったん消す
    kill();
  }

  /**
   * 初期化
   **/
  public function init(X:Float, Y:Float, target:Actor, item:ItemData):Void {
    x = X;
    y = Y;
    _target = target;
    _item = item;

    // ランダムな速度を設定
    var speed = FlxRandom.floatRanged(20, 200);
    // 目標と反対側の角度を設定
    var deg = FlxAngle.angleBetween(this, _target, true);
    deg -= 180;

    velocity.x = speed * Math.cos(deg * FlxAngle.TO_RAD);
    velocity.y = speed * -Math.sin(deg * FlxAngle.TO_RAD);
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // 拡縮アニメ
    var sc = FlxRandom.floatRanged(0.4, 0.5);
    scale.set(sc, sc);

    // 衝突判定
    {
      var dx = _target.x - x;
      var dy = _target.y - y;
      if(16*16 > dx*dx + dy*dy) {
        // 衝突
        MagicShotMgr.hitTarget(_target, _item);
        kill();
        return;
      }
    }

    // ホーミング移動する
    _homing();

  }

  /**
   * 目標に向かってホーミング移動する
   **/
  private function _homing():Void {
    var ax = velocity.x;
    var ay = velocity.y;
    var bx = _target.x - x;
    var by = _target.y - y;
    var speed = Math.sqrt(ax*ax + ay*ay);
    var deg = Math.atan2(-ay, ax) * FlxAngle.TO_DEG;
    // 角速度
    var dDeg = ROT_SPEED_MAX * Math.sin(speed/SPEED_MAX*90*FlxAngle.TO_RAD);
    // 加速
    speed += 30;
    if(speed > SPEED_MAX) {
      speed = SPEED_MAX;
    }

    var cos = (ax * bx + ay * by) / (Math.sqrt(ax*ax + ay*ay) * Math.sqrt(bx*bx + by*by));
    var cosDeg = Math.acos(cos) * FlxAngle.TO_DEG;
    if(Math.isNaN(cosDeg)) {
      cosDeg = 0;
    }
    if(cosDeg < dDeg) {
      dDeg = cosDeg;
    }
    var cross = ax * by - ay * bx;
    if(cross > 0) {
      // 反時計回り
      deg -= dDeg;
    }
    else {
      // 時計回り
      deg += dDeg;
    }
    velocity.x = speed * Math.cos(deg * FlxAngle.TO_RAD);
    velocity.y = speed * -Math.sin(deg * FlxAngle.TO_RAD);
  }
}
