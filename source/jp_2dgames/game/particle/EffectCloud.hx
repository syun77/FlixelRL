package jp_2dgames.game.particle;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.util.FlxRandom;
import flixel.group.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * 状態
 **/
private enum State {
  Appear;
  Main;
  Vanish;
}

/**
 * 雲エフェクト
 **/
class EffectCloud extends FlxSprite {
  public static inline var MAX_CLOUD:Int = 16;

  public static var parent:FlxTypedGroup<EffectCloud>;

  /**
   * 出現開始
   **/
  public static function start() {
    for(i in 0...MAX_CLOUD) {
      var c:EffectCloud = parent.recycle();
      c.init(i);
    }
  }

  /**
   * 消滅開始
   **/
  public static function killAll() {
    parent.forEachAlive(function(c:EffectCloud) {
      c.requestKill();
    });
  }

  /**
   * 出現しているかどうか
   **/
  public static function isAppear():Bool {
    return parent.countLiving() > 0;
  }

  private var _state:State = State.Appear;
  private var _alpha:Float = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    kill();
  }

  /**
   * 初期化
   **/
  public function init(i:Int):Void {
    x = FlxRandom.floatRanged(-FlxG.width/5, FlxG.width);
    y = FlxRandom.floatRanged(-FlxG.height/5, FlxG.height);
    var idx = FlxRandom.intRanged(1, 4);
    var cloud = loadGraphic('assets/images/title/cloud${idx}.png');
    if(y > FlxG.height - height) {
      y = FlxRandom.floatRanged(0, FlxG.height-height/2);
    }
    var vx = -10 - 5 * i;
    var vy = FlxRandom.floatRanged(-10, 10);
    velocity.set(vx, vy);
    _alpha = FlxRandom.floatRanged(0.4, 0.8);

    // 出現開始
    _state = State.Appear;
    alpha = 0;
    color = FlxColor.BLACK;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Appear:
        // 出現開始
        alpha += 0.001;
        if(alpha > _alpha) {
          _state = State.Main;
        }

      case State.Main:
        // メイン処理

      case State.Vanish:
        // 消滅中
        alpha -= 0.01;
        if(alpha < 0) {
          kill();
        }
    }

    if(x + width < 0) {
      x = FlxG.width;
    }
    if(y < -height) {
      y = FlxG.height;
    }
    if(y > FlxG.height) {
      y = -height;
    }
  }

  /**
   * 消滅要求
   **/
  public function requestKill():Void {
    _state = State.Vanish;
  }

}

