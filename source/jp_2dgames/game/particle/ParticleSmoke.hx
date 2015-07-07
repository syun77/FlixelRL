package jp_2dgames.game.particle;
import flixel.util.FlxColor;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxAngle;
import flixel.FlxSprite;

/**
 * パーティクル（煙）
 **/
class ParticleSmoke extends FlxSprite {

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleSmoke>;

  public static function start(type:String, X:Float, Y:Float):Void {
    var p:ParticleSmoke = parent.recycle();
    p.init(type, X, Y, 90, 50);
  }

  /**
	 * コンストラクタ
	 **/
  public function new() {
    super();
    loadGraphic("assets/images/smoke.png", true);

    // アニメーション登録
    animation.add("enemy", [0, 1,  2,  3,  4,  5,  6,  7,  8], 16, false);
    animation.add("warp",  [9, 10, 11, 12, 13, 14, 15, 16, 17], 16, false);
    animation.add("drill", [9, 10, 11, 12, 13, 14, 15, 16, 17], 16, false);

    // 中心を基準に描画
    offset.set(width / 2, height / 2);

    alpha = 1;

    // 非表示
    kill();
  }

  /**
	 * 初期化
	 **/

  public function init(type:String, X:Float, Y:Float, direction:Float, speed:Float):Void {
    animation.play(type);
    if(type == "drill") {
      color = FlxColor.BROWN;
    }
    else {
      color = FlxColor.WHITE;
    }

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

    alpha -= 0.04;
    if(alpha < 0) {
      alpha = 0;
    }

    if(animation.finished) {
      kill();
    }
  }
}
