package jp_2dgames.game.state;
import jp_2dgames.lib.Snd;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import jp_2dgames.lib.CsvLoader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.util.BgWrap;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = OnEnter;
    leaveCallback = OnLeave;
  }
}

/**
 * 統計メニュートップ画面
 **/
class StatsState extends FlxState {

  // ■定数
  private static inline var MENU_Y = 80;
  private static inline var MENU_DY = 64;

  // ■メンバ変数
  private var _csv:CsvLoader;
  // ポップアップテキスト
  private var _txtTip:FlxText = null;
  // ポップアップの枠
  private var _sprTip:FlxSprite = null;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // カーソル表示
    FlxG.mouse.visible = true;

    // 背景
    this.add(new BgWrap(false));

    // CSV読み込み
    _csv = new CsvLoader("assets/data/stats.csv");

    // ポップアップテキスト
    {
      _txtTip = new FlxText(0, 0, 280, "");
      _txtTip.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      _txtTip.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.GREEN);
      _txtTip.color = FlxColor.WHITE;
      _txtTip.visible = false;

      _sprTip = new FlxSprite(0, 0);
      _sprTip.makeGraphic(280, 24, FlxColor.BLACK);
      _sprTip.alpha = 0.5;
      _sprTip.visible = false;
    }

    var btnList = new List<MyButton>();

    var px = FlxG.width;
    var py = MENU_Y;

    // STATISTICS
    btnList.add(new MyButton(px, py, "STATISTICS", function() {
      // プレイデータを見る
      FlxG.switchState(new StatisticsState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(1, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += MENU_DY;

    // ACHIEVEMENT
    btnList.add(new MyButton(px, py, "ACHIEVEMENT", function() {
      // ACHIEVEMENTを見る
      FlxG.switchState(new AchievementState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(2, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += MENU_DY;

    // PLAY LOG
    btnList.add(new MyButton(px, py, "HISTORY", function() {
      // PLAY LOGを見る
      FlxG.switchState(new PlayLogState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(3, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += MENU_DY;

    // ENEMY LOG
    btnList.add(new MyButton(px, py, "ENEMY LOG", function() {
      // ENEMY LOGを見る
      FlxG.switchState(new EnemyLogState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(4, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += MENU_DY;

    // ITEM LOG
    btnList.add(new MyButton(px, py, "ITEM LOG", function() {
      // ITEM LOGを見る
      FlxG.switchState(new ItemLogState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(5, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += Std.int(MENU_DY * 1.3);
    // BACK
    btnList.add(new MyButton(px, py, "BACK", function() {
      // タイトル画面に戻る
      FlxG.switchState(new TitleState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(6, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    // メニューが入る演出
    var px2 = FlxG.width/2 - 100;
    var idx:Int = 0;
    for(btn in btnList) {
      FlxTween.tween(btn, {x:px2}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.1});
      this.add(btn);
      idx++;
    }

    this.add(_sprTip);
    this.add(_txtTip);
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

    // ヘルプチップ更新
    if(_txtTip != null) {
      _txtTip.x = FlxG.mouse.x+16;
      _txtTip.y = FlxG.mouse.y-24;
      _sprTip.x = _txtTip.x;
      _sprTip.y = _txtTip.y;
      _sprTip.visible = _txtTip.visible;
    }
  }
}
