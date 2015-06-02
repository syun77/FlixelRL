package jp_2dgames.game.particle;
import flash.display.BlendMode;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * パーティクル（敵出現）
 **/
class ParticleEnemy extends FlxSprite {

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleEnemy>;

  public static function start(X:Float, Y:Float):Void {
    trace(parent);
    var p:ParticleEnemy = parent.recycle();
    p.init(X, Y, 90, 50);
  }

  /**
	 * コンストラクタ
	 **/
  public function new() {
    super();
    loadGraphic("assets/images/explosion.png", true);

    // アニメーション登録
    animation.add("play", [0, 1, 2, 3, 4, 5, 6, 7, 8], 16, false);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    alpha = 1;

    // 非表示
    kill();
  }

  /**
	 * 初期化
	 **/

  public function init(X:Float, Y:Float, direction:Float, speed:Float):Void {
    animation.play("play");

    // 座標と速度を設定
    x = X;
    y = Y;
    var rad = FlxAngle.asRadians(direction);
    velocity.x = Math.cos(rad) * speed;
    velocity.y = -Math.sin(rad) * speed;

    // 初期化
    alpha = 1.0;
  }

  /**
	 * 更新
	 **/

  override public function update():Void {
    super.update();

    alpha -= 0.02;
    if(alpha < 0) {
      alpha = 0;
    }

    if(animation.finished) {
      kill();
    }
  }
}
