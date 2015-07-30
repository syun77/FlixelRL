package jp_2dgames.game.state;
import flash.filters.BlurFilter;
import flash.filters.BitmapFilter;
import flixel.effects.FlxSpriteFilter;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;
  }
}

/**
 * タイトル画面
 **/
class TitleState extends FlxState {

  // ■定数
  private static inline var USER_NAME_POS_X = 8;
  private static inline var USER_NAME_OFS_Y = -60;

  // ■メンバ変数
  // PLEASE CLICK ボタン
  private var _btnClick:MyButton;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景画像
    var bg = new FlxSprite(0, 0, "assets/images/title.png");
    this.add(bg);
    // フェード表示
    bg.alpha = 0;
    FlxTween.tween(bg, {alpha:0.8}, 1, {ease:FlxEase.expoOut});

    // クリックボタン
    var px = FlxG.width/2 - 100;
    var py = FlxG.height/2;
    _btnClick = new MyButton(px, py, "PLEASE CLICK", function() {
      // 背景を暗くする
      FlxTween.color(bg, 1, FlxColor.WHITE, FlxColor.CHARCOAL, {ease:FlxEase.expoOut});
      // ブラーフィルタ適用
      var filter = new FlxSpriteFilter(bg);
      var blur = new BlurFilter(8, 8);
      filter.addFilter(blur);
      filter.applyFilters();
      // メニュー表示
      _appearMenu();
    });
    this.add(_btnClick);
  }

  /**
   * メニュー表示
   **/
  private function _appearMenu():Void {

    // ユーザー名
    var py = FlxG.height + USER_NAME_OFS_Y;
    var txtUserName = new FlxText(-480, py, 480, "", 20);
    txtUserName.text = "YOUR NAME: " + GameData.getName();
    FlxTween.tween(txtUserName, {x:USER_NAME_POS_X}, 1, {ease:FlxEase.expoOut});
    this.add(txtUserName);

    // 各種ボタン
    var px = FlxG.width/2 - 100;
    var py = 128;
    this.add(new MyButton(px, py, "NEW GAME", function(){ FlxG.switchState(new PlayInitState()); }));
    py += 64;
    var btnContinue = new MyButton(px, py, "CONTINUE", function() {
      // セーブデータから読み込み
      Global.SetLoadGame(true);
      FlxG.switchState(new PlayState());
    });
    if(Save.isContinue()) {
      py += 64;
      this.add(btnContinue);
    }
    this.add(new MyButton(px, py, "OPENING", function(){ FlxG.switchState(new OpeningState()); }));
    py += 64;
    this.add(new MyButton(px, py, "ENDING", function(){ FlxG.switchState(new EndingState()); }));
    py += 64;
    this.add(new MyButton(px, py, "RESET", function(){
      Save.erase();
      btnContinue.kill();
    }));
    py += 64;
    this.add(new MyButton(px, py, "NAME ENTRY", function(){ FlxG.switchState(new NameEntryState()); }));

    // ボタンを消しておく
    _btnClick.kill();
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

  #if debug
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminaite.";
    }
  #end
  }
}
