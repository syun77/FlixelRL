package jp_2dgames.game.particle;

import StringTools;
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
  Fadeout; // 消える
}

/**
 * レベルエフェクト
 **/
class ParticleMessage extends FlxSprite {

  // フォントサイズ
  private static inline var FONT_SIZE:Int = 16;

  // ■速度関連
  // 開始速度
  private static inline var SPEED_Y_INIT:Float = -20;

  // パーティクル管理
  public static var parent:FlxTypedGroup<ParticleMessage>;

  public static function start(X:Float, Y:Float, msg:String, color:Int=FlxColor.WHITE):Void {
    var p:ParticleMessage = parent.recycle();
    p.init(X, Y, msg, color);
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

    // 非表示にしておく
    kill();
  }

  /**
	 * 初期化
	 **/
  public function init(X:Float, Y:Float, msg:String, color:Int) {
    x = X;
    y = Y;
    _ystart = Y;
    this.color = color;

    // 描画をクリアする
    pixels.fillRect(new Rectangle(0, 0, FONT_SIZE * 8, FONT_SIZE), FlxColor.TRANSPARENT);

    // フォント画像読み込み
    var bmp = FlxG.bitmap.add("assets/font/font16x16.png");
    var pt = new Point();
    var rect = new Rectangle(0, 0, FONT_SIZE, FONT_SIZE);
    // 文字数を求める
    var length = msg.length;
    for(i in 0...length) {
      // フォントをレンダリングする
      pt.x = i * FONT_SIZE;
      var v = (StringTools.fastCodeAt(msg, i));
      if(v == 0x20) {
        // スペースは何も描画しない
        continue;
      }
      v = v - 0x41 + 10;
      rect.left = v * FONT_SIZE;
      rect.right = rect.left + FONT_SIZE;
      pixels.copyPixels(bmp.bitmap, rect, pt);
    }
    dirty = true;
    updateFrameData();

    // フォントを中央揃えする
    x = X - (FONT_SIZE * length / 2);

    // 移動開始
    velocity.y = SPEED_Y_INIT;

    alpha = 1;

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
          // 半透明で消える
          _state = State.Fadeout;
        }
      case State.Fadeout:
        alpha -= 0.06;
        if(alpha < 0.05) {
          kill();
        }

    }

  }
}
