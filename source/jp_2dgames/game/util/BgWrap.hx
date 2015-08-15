package jp_2dgames.game.util;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

/**
 * 無限スクロールする背景
 **/
class BgWrap extends FlxSpriteGroup {

  // 背景画像
  private static inline var IMAGE_TILE = "assets/levels/tilenone.png";
  // 移動速度
  private static inline var SPEED = -50;
  // タイルサイズ
  private static inline var SIZE:Int = Field.GRID_SIZE*2;

  private var _cntX:Int;
  private var _cntY:Int;

  public function new() {
    super();

    var cntX = Std.int(FlxG.width / SIZE) + 2;
    var cntY = Std.int(FlxG.height / SIZE) + 2;
    _cntX = cntX - 1;
    _cntY = cntY - 1;

    for(j in 0...cntY) {
      for(i in 0...cntX) {
        // 初期座標を設定
        var px = i * SIZE;
        var py = j * SIZE;
        var bg = new FlxSprite(px, py, IMAGE_TILE);
        // 移動速度 (スキマが見えない用にサイズをもとに調整する)
        var speed = SIZE / FlxG.updateFramerate * SPEED;
        bg.velocity.set(speed, speed);
        // 画像のサイズが32x32なので、SIZE(=64)に合わせる)
        bg.scale.set(2, 2);
        // 黒フェードイン
        FlxTween.color(bg, 2, FlxColor.BLACK, FlxColor.GRAY, 1, 1, {ease:FlxEase.expoOut});
        this.add(bg);
      }
    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    for(bg in this.group) {
      if(bg.x < -SIZE) {
        // 左の外側に出たので、右側に移動
        bg.x += SIZE * (_cntX + 1);
      }
      if(bg.y < -SIZE) {
        // 上の外側に出たので、下側に移動
        bg.y += SIZE * (_cntY + 1);
      }
    }
  }
}
