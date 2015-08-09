package jp_2dgames.game.state;
import flash.external.ExternalInterface;
import openfl.display.StageDisplayState;
import flixel.ui.FlxButton;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.util.Key;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.util.Pad;
import flixel.util.FlxRandom;
import jp_2dgames.game.event.EventNpc;
import jp_2dgames.game.util.DirUtil;
import flash.display.BlendMode;
import flash.filters.BlurFilter;
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
 * 状態
 **/
private enum State {
  Logo; // ロゴ
  Main; // メイン
}

/**
 * タイトル画面
 **/
class TitleState extends FlxState {

  // ■定数

  // ロゴ
  private static inline var LOGO_Y = -160;
  private static inline var LOGO_Y2 = 64;
  private static inline var LOGO_SIZE = 64;

  // ロゴ背景
  private static inline var LOGO_BG_Y = LOGO_Y2 + LOGO_SIZE/2;

  // ユーザ名
  private static inline var USER_NAME_POS_X = 8;
  private static inline var USER_NAME_OFS_Y = -92;
  // ハイスコア
  private static inline var HISCORE_POS_X = USER_NAME_POS_X;
  private static inline var HISCORE_OFS_Y = USER_NAME_OFS_Y + 32;

  // ■static変数
  // ビッグサイズかどうか
  private static var _bBigSize:Bool = false;

  // ■メンバ変数
  private var _bg:FlxSprite;
  private var _bgLogo:FlxSprite;
  private var _txtLogo:FlxText;
  private var _txtCopyright:FlxText;

  // PLEASE CLICK ボタン
  private var _btnClick:MyButton;
  // プレイヤー名
  private var _txtUserName:FlxText = null;
  // 背景ロゴアニメ
  private var _tweenBgLog:FlxTween;

  // 流れる雲
  private var _clouds:Array<FlxSprite>;

  // CSVテキスト
  private var _csv:CsvLoader;
  // ポップアップテキスト
  private var _txtTip:FlxText = null;
  // ポップアップの枠
  private var _sprTip:FlxSprite = null;

  // 状態
  private var _state:State = State.Logo;


  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景画像
    _bg = new FlxSprite(0, 0, "assets/images/title/bg.png");
    this.add(_bg);
    // フェード表示
    var a = 0.8; // アルファ値
    _bg.alpha = 0;
    FlxTween.tween(_bg, {alpha:a}, 1, {ease:FlxEase.expoOut});
    // スクロール
    _bg.y = -_bg.height + FlxG.height;
    FlxTween.tween(_bg, {y:0}, 30, {type:FlxTween.PINGPONG, ease:FlxEase.sineOut});

    // 太陽の光
    var sunbeam = new FlxSprite(0, 0, "assets/images/title/sunbeam.png");
    this.add(sunbeam);
    sunbeam.blend = BlendMode.ADD;
    sunbeam.alpha = 0.3;
    FlxTween.tween(sunbeam, {alpha:0.8}, 5, {ease:FlxEase.sineInOut, type:FlxTween.PINGPONG});

    // 雲
    _clouds = new Array<FlxSprite>();
    for(i in 0...16) {
      var x = FlxRandom.floatRanged(-FlxG.width/5, FlxG.width);
      var y = FlxRandom.floatRanged(-FlxG.height/5, FlxG.height);
      var idx = FlxRandom.intRanged(1, 4);
      var cloud = new FlxSprite(x, y, 'assets/images/title/cloud${idx}.png');
      if(cloud.y > FlxG.height - cloud.height) {
        cloud.y = FlxRandom.floatRanged(0, FlxG.height-cloud.height/2);
      }
      this.add(cloud);
      _clouds.push(cloud);
      var vx = -10 - 5 * i;
      var vy = FlxRandom.floatRanged(-10, 10);
      cloud.velocity.set(vx, vy);
      cloud.alpha = FlxRandom.floatRanged(0.5, 1);
    }

    // ロゴの背景
    _bgLogo = new FlxSprite(FlxG.width/2, LOGO_BG_Y).makeGraphic(FlxG.width, 8, FlxColor.WHITE);
    _bgLogo.blend = BlendMode.ADD;
    _bgLogo.x = 0;
    _bgLogo.scale.x = 0;
    FlxTween.tween(_bgLogo.scale, {x:1}, 1, {ease:FlxEase.expoIn});
    _tweenBgLog = FlxTween.color(_bgLogo, 2, FlxColor.CHARCOAL, FlxColor.GRAY, 0.5, 0.5, {ease:FlxEase.sineInOut, type:FlxTween.PINGPONG});
    {
      var filter = new FlxSpriteFilter(_bgLogo);
      var blur = new BlurFilter(0, 8);
      filter.addFilter(blur);
      filter.applyFilters();
    }
    this.add(_bgLogo);

    // タイトルロゴ
    _txtLogo = new FlxText(FlxG.width/2, LOGO_Y2, 320, "1 Rogue", LOGO_SIZE);
    _txtLogo.color = FlxColor.WHITE;
    _txtLogo.x -= _txtLogo.width/2;
    _txtLogo.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.GOLDENROD, 8);
    this.add(_txtLogo);
//    FlxTween.tween(txtLogo, {y:LOGO_Y2}, 1, {ease:FlxEase.expoOut});

    // コピーライト
    _txtCopyright = new FlxText(FlxG.width/2, FlxG.height-32, 480);
    _txtCopyright.x = _txtCopyright.width/2;
    _txtCopyright.text = "(c) 2015 2dgames.jp All right reserved.";
    _txtCopyright.setFormat(null, 16);
    this.add(_txtCopyright);

    // クリックボタン
    var px = FlxG.width/2 - 100;
    var py = FlxG.height/2;
    _btnClick = new MyButton(px, py, "PLEASE CLICK", function() {
      // メインメニューへ遷移
      _changeMainMenu();
    }, function() {
      Snd.playSe("pi", true);
    });
    this.add(_btnClick);

    if(GameData.bitCheck(GameData.FLG_FIRST_DONE) == false) {
      // 初回起動時はネームエントリを表示
      openSubState(new NameEntryState());
      GameData.bitOn(GameData.FLG_FIRST_DONE);
    }

    // フルスクリーン切り替えボタン
    var btnFullScreen:FlxButton = null;
#if flash
    btnFullScreen = new FlxButton(FlxG.width, 32, "BIG SIZE", function() {
      if(_bBigSize == false) {
        // サイズを大きくする
        flash.external.ExternalInterface.call("ResizeSwf", "FlixelRL", 1136, 640);
        btnFullScreen.text = "NORMAL";
        _bBigSize = true;
      }
      else {
        // 通常に戻す
        flash.external.ExternalInterface.call("ResizeSwf", "FlixelRL", 852, 480);
        btnFullScreen.text = "BIG SIZE";
        _bBigSize = false;
      }
    });
    if(_bBigSize) {
      btnFullScreen.text = "NORMAL";
    }
#else
    btnFullScreen = new FlxButton(FlxG.width, 32, "FULL SCREEN", function() {
      if(FlxG.stage.displayState == StageDisplayState.NORMAL) {
        // フルスクリーン
        FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
        btnFullScreen.text = "NORMAL";
      }
      else {
        // 通常に戻す
        FlxG.stage.displayState = StageDisplayState.NORMAL;
        btnFullScreen.text = "FULL SCREEN";
      }
    });
    if(FlxG.stage.displayState == StageDisplayState.FULL_SCREEN) {
      btnFullScreen.text = "NORMAL";
    }
#end
    this.add(btnFullScreen);
    FlxTween.tween(btnFullScreen, {x:btnFullScreen.x-88}, 1, {ease:FlxEase.expoOut, startDelay:1});

    // 白フェードで開始
    FlxG.camera.fade(FlxColor.WHITE, 1.5, true);

    // マウスカーソル表示
    FlxG.mouse.visible = true;
  }

  /**
   * メインメニューに遷移
   **/
  private function _changeMainMenu():Void {
    // ボタンを消しておく
    _btnClick.kill();

    // 決定SE
    Snd.playSe("equip", true);

    // メイン状態へ
    _state = State.Main;

    // 背景を暗くする
    FlxTween.color(_bg, 1, FlxColor.WHITE, FlxColor.GRAY, 0.8, 0.8, {ease:FlxEase.expoOut});
    // ロゴを追い出す
    FlxTween.tween(_txtLogo, {y:LOGO_Y}, 1, {ease:FlxEase.expoOut});
    // ロゴ背景を消す
    FlxTween.tween(_bgLogo, {alpha:0.0}, 1, {ease:FlxEase.expoOut});
    // 点滅アニメ終了
    _tweenBgLog.cancel();
    // コピーライトを追い出す
    FlxTween.tween(_txtCopyright, {y:FlxG.height+32}, 1, {ease:FlxEase.expoOut});
    // メニュー表示
    _appearMenu();
  }

  /**
   * メニュー表示
   **/
  private function _appearMenu():Void {

    // ユーザー名
    {
      var py = FlxG.height + USER_NAME_OFS_Y;
      _txtUserName = new FlxText(-480, py, 480, "", 20);
      FlxTween.tween(_txtUserName, {x:USER_NAME_POS_X}, 1, {ease:FlxEase.expoOut});
      this.add(_txtUserName);
    }

    // ハイスコア
    {
      var py = FlxG.height + HISCORE_OFS_Y;
      var txtHiscore = new FlxText(-480, py, 480, "", 20);
      var hiscore = GameData.getHiscore();
      txtHiscore.text = 'HI-SCORE: ${hiscore}';
      FlxTween.tween(txtHiscore, {x:HISCORE_POS_X}, 1, {ease:FlxEase.expoOut, startDelay:0.1});
      this.add(txtHiscore);
    }

    // プレイヤー表示
    var player = new EventNpc();
    player.revive();
    player.init("player", 1, 11, Dir.Down);
    this.add(player);

    // CSV
    _csv = new CsvLoader("assets/data/title.csv");

    // ポップアップテキスト
    {
      _txtTip = new FlxText(0, 0, 400, "");
      _txtTip.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      _txtTip.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.GREEN);
      _txtTip.color = FlxColor.WHITE;
      _txtTip.visible = false;

      _sprTip = new FlxSprite(0, 0);
      _sprTip.makeGraphic(400, 24, FlxColor.BLACK);
      _sprTip.alpha = 0.5;
      _sprTip.visible = false;
    }

    // 各種ボタン
    var btnList = new List<MyButton>();
    var px = FlxG.width;
    var py = 160;
    // NEW GAME
    btnList.add(new MyButton(px, py, "NEW GAME", function() {
      // NEW GAMEで始める
      _startNewGame();
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(1, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    py += 64;
    // CONTINUE
    var btnContinue = new MyButton(px, py, "CONTINUE", function() {
      // CONTINUEで始める
      _startContinue();
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(2, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    });
    if(Save.isContinue()) {
      py += 64;
      btnList.add(btnContinue);
    }
    // NAME ENTRY
    btnList.add(new MyButton(px, py, "NAME ENTRY", function() {
      Snd.playSe("equip", true);
      // HACK: SubStatから戻ってきたときに再び呼び出されてしまうため
      if(subState == null) {
        openSubState(new NameEntryState());
      }
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(3, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));
    py += 64;

    if(GameData.bitCheck(GameData.FLG_FIRST_GAME_DONE)) {
      // 初回ゲーム済みのみ表示
      // OPENING
      btnList.add(new MyButton(px, py, "OPENING", function() {
        Snd.playSe("equip", true);
        FlxG.switchState(new OpeningState());
      },
        function() {
          _txtTip.visible = true;
          _txtTip.text = _csv.getString(4, "msg");
          Snd.playSe("pi", true);
        },
        function() {
          _txtTip.visible = false;
        }
      ));
    }

    var px2 = FlxG.width/2 - 100;
    var idx:Int = 0;
    for(btn in btnList) {
      FlxTween.tween(btn, {x:px2}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.1});
      this.add(btn);
      idx++;
    }

    // ヘルプチップ登録
    this.add(_sprTip);
    this.add(_txtTip);
  }

  /**
   * NEW GAMEを開始
   **/
  private function _startNewGame():Void {
    Snd.playSe("equip", true);
    if(GameData.bitCheck(GameData.FLG_FIRST_GAME_DONE) == false) {
      // オープニングをまだ見ていない
      GameData.bitOn(GameData.FLG_FIRST_GAME_DONE);
      FlxG.switchState(new OpeningState());
    }
    else {
      // すでに見た
      FlxG.switchState(new PlayInitState());
    }
  }

  /**
   * CONTINUEで開始
   **/
  private function _startContinue():Void {
    Snd.playSe("equip", true);
    // セーブデータから読み込み
    Global.SetLoadGame(true);
    FlxG.switchState(new PlayState());
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();

    // マウスカーソル非表示
    FlxG.mouse.visible = false;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // ゲームパッド更新
    Pad.update();

    switch(_state) {
      case State.Logo:
        if(Key.press.A) {
          // メインメニューへ遷移
          _changeMainMenu();
        }

      case State.Main:
        if(Key.press.A) {
          if(Save.isContinue()) {
            // セーブデータがあればCONTINUE
            _startContinue();
          }
          else {
            // そうでなければNEW GAME
            _startNewGame();
          }
        }
    }

    // ヘルプチップ更新
    if(_txtTip != null) {
      _txtTip.x = FlxG.mouse.x+16;
      _txtTip.y = FlxG.mouse.y-24;
      _sprTip.x = _txtTip.x;
      _sprTip.y = _txtTip.y;
      _sprTip.visible = _txtTip.visible;
    }

    for(cloud in _clouds) {
      if(cloud.x + cloud.width < 0) {
        cloud.x = FlxG.width;
      }
      if(cloud.y < -cloud.height) {
        cloud.y = FlxG.height;
      }
      if(cloud.y > FlxG.height) {
        cloud.y = -cloud.height;
      }
    }

    if(_txtUserName != null) {
      // ユーザ名更新
      _txtUserName.text = "YOUR NAME: " + GameData.getName();
    }

    if(FlxG.keys.pressed.D && FlxG.keys.pressed.SHIFT) {
      // デバッグコマンド
      FlxG.switchState(new DebugState());
    }

  #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.switchState(new TitleState());
    }
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminaite.";
    }
  #end
  }
}
