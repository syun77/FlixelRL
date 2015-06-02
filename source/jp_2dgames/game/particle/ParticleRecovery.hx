package jp_2dgames.game.particle;

import flash.geom.Rectangle;
import flash.geom.Point;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

/**
 * 状態
 **/
private enum State {
  Main;  // メイン
  Blink; // 点滅
}

/**
 * HP回復エフェクト
 **/
class ParticleRecovery extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = 16;

  // ■速度関連
  // 開始速度
  private static inline var SPEED_Y_INIT:Float = -20;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleRecovery>;

  public static function start(X:Float, Y:Float, val:Int):Void {
    var p:ParticleRecovery = parent.recycle();
    p.init(X, Y, val);
  }

  // 開始座標
  private var _ystart:Float;
  private var _state:State;
  private var _timer:Int;

  /**
	 * コンストラクタ
	 **/

  public function new() {
    super();

    makeGraphic(FONT_SIZE * 8, FONT_SIZE, FlxColor.TRANSPARENT, true);
    color = FlxColor.CHARTREUSE;

    // 非表示にしておく
    kill();
  }

  /**
	 * 初期化
	 **/

  public function init(X:Float, Y:Float, val:Int) {
    x = X;
    y = Y;
    _ystart = Y;

    // 描画をクリアする
    pixels.fillRect(new Rectangle(0, 0, FONT_SIZE * 8, FONT_SIZE), FlxColor.TRANSPARENT);

    // フォント画像読み込み
    var bmp = FlxG.bitmap.add("assets/font/font16x16.png");
    var pt = new Point();
    var rect = new Rectangle(0, 0, FONT_SIZE, FONT_SIZE);
    // 数字の桁数を求める
    var digit = Std.string(val).length;
    for(i in 0...digit) {
      // フォントをレンダリングする
      pt.x = (digit - i - 1) * FONT_SIZE;
      var v = Std.int(val / Math.pow(10, i)) % 10;
      rect.left = v * FONT_SIZE;
      rect.right = rect.left + FONT_SIZE;
      pixels.copyPixels(bmp.bitmap, rect, pt);
    }
    dirty = true;
    updateFrameData();

    // フォントを中央揃えする
    x = X - (FONT_SIZE * digit / 2);

    // 移動開始
    velocity.y = SPEED_Y_INIT;

    visible = true;

    // メイン状態へ
    _timer = 60;
    _state = State.Main;
  }

  /**
	 * コンストラクタ
	 **/

  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        _timer--;
        if(_timer < 1) {
          // 点滅開始
          _timer = 15;
          _state = State.Blink;
        }
      case State.Blink:
        // 点滅して消える
        visible = (_timer % 4 >= 2);
        _timer--;
        if(_timer < 1) {
          kill();
        }
    }

  }
}
