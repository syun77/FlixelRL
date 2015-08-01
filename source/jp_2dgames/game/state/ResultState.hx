package jp_2dgames.game.state;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 160; // ボタンの幅
    var h = 32;  // ボタンの高さ
    var s = 16;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = OnEnter;
    leaveCallback = OnLeave;

    #if neko
    buttonNormal.color = FlxColor.GREEN;
    buttonHighlight.color = FlxColor.RED;
#end
  }
}

/**
 * リザルト画面
 **/
class ResultState extends FlxState {

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0;
    this.add(bg);
    FlxTween.tween(bg, {alpha:0.5}, 1, {ease:FlxEase.expoOut});

    // キャプション
    var px = 32;
    var py = 32;
    var txtCaption = new FlxText(px, py, 480, "GAME RANKING", 32);
    this.add(txtCaption);

    py += 96;
    // スコア
    var score = Global.getScore();
    var txtFloor = new FlxText(px, py, 480, 'Score: ${score}', 32);
    this.add(txtFloor);

    py += 96;
    // 到達階
    var floor = Global.getFloor();
    var txtFloor = new FlxText(px, py, 480, 'Floor: ${floor}', 32);
    this.add(txtFloor);

    py += 96;
    // ランク
    var rank = "Dragon Master";
    var txtFloor = new FlxText(px, py, 480, 'Rank: ${rank}', 32);
    this.add(txtFloor);

    // 女の子
    var sprGirl = new FlxSprite(FlxG.width, 0, "assets/images/result.png");
    this.add(sprGirl);
    FlxTween.tween(sprGirl, {x:FlxG.width/2}, 1, {ease:FlxEase.expoOut});

    // OKボタン
    var btn = new MyButton(FlxG.width/2 - 80, FlxG.height-64, "OK", function() {
      // タイトルに戻る
      FlxG.switchState(new TitleState());
    });
    this.add(btn);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }

}
