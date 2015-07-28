package jp_2dgames.game.state;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.GameData;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxButtonPlus;
import jp_2dgames.game.util.NameGenerator;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

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
  }
}

/**
 * 名前入力画面
 **/
class NameEntryState extends FlxState {

  // 名前に設定可能な最大文字数
  private static inline var MAX_NAME:Int = 8;

  // ヘルプテキスト
  private static inline var HELP_X = 200;
  private static inline var HELP_Y = 60;

  // 名前テキストの座標
  private static inline var NAME_X = 256;
  private static inline var NAME_Y = 128;
  private static inline var NAME_W = 160;

  // 消去ボタン
  private static inline var CLEAR_X = NAME_X + 180;
  private static inline var CLEAR_Y = NAME_Y;

  // 自動入力ボタン
  private static inline var MALE_X = 240;
  private static inline var MALE_Y = 260;
  private static inline var FEMALE_X = MALE_X + 200;
  private static inline var FEMALE_Y = MALE_Y;

  // 戻る
  private static inline var BACK_X = 320;
  private static inline var BACK_Y = 400;

  // 名前自動生成
  private var _generator:NameGenerator;
  // 名前入力説明テキスト
  private var _txtHelp:FlxText;
  // 名前入力の枠
  private var _sprName:FlxSprite;
  // 名前テキスト
  private var _txtName:FlxText;
  // CSVテキスト
  private var _csv:CsvLoader;
  // ポップアップテキスト
  private var _txtTip:FlxText;
  // ポップアップの枠
  private var _sprTip:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // CSVテキスト
    _csv = new CsvLoader("assets/data/nameentry.csv");

    // 名前説明
    {
      var msg = _csv.getString(1, "msg");
      _txtHelp = new FlxText(HELP_X, HELP_Y, 480, msg);
      _txtHelp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      this.add(_txtHelp);
    }

    // 自動入力
    _generator = new NameGenerator();

    // 名前入力の枠
    _sprName = new FlxSprite(NAME_X-8, NAME_Y-8);
    _sprName.makeGraphic(NAME_W, Reg.FONT_SIZE*2, FlxColor.CORAL);
    {
      var w = _sprName.width;
      var h = _sprName.height;
      var rect = new Rectangle(2, 2, w-4, h-4);
      _sprName.pixels.fillRect(rect, 0x802010);
      _sprName.dirty = true;
      _sprName.updateFrameData();
    }
    this.add(_sprName);

    // 名前入力
    _txtName = new FlxText(NAME_X, NAME_Y, NAME_W, "", 24);
    this.add(_txtName);

    // ポップアップテキスト
    _txtTip = new FlxText(0, 0, 320, "");
    _txtTip.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    _txtTip.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.GREEN);
    _txtTip.color = FlxColor.WHITE;
    _txtTip.visible = false;

    _sprTip = new FlxSprite(0, 0);
    _sprTip.makeGraphic(320, 24, FlxColor.BLACK);
    _sprTip.alpha = 0.5;
    _sprTip.visible = false;

    // 名前消去
    this.add(new MyButton(CLEAR_X, CLEAR_Y, "CLEAR", function() {
      _setName("");
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(2, "msg");
    }, function() {
      _txtTip.visible = false;
    }));

    // 自動入力（男性）
    this.add(new MyButton(MALE_X, MALE_Y, "MALE", function() {
      _setName(_generator.getMale());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(3, "msg");
    }, function() {
      _txtTip.visible = false;
    }));

    // 自動入力（女性）
    this.add(new MyButton(FEMALE_X, FEMALE_Y, "FEMALE", function() {
      _setName(_generator.getFemale());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(4, "msg");
    }, function() {
      _txtTip.visible = false;
    }));

    // 戻るボタン
    this.add(new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new TitleState());
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(5, "msg");
    }, function() {
      _txtTip.visible = false;
    }));

    this.add(_sprTip);
    this.add(_txtTip);

    _setName(GameData.getName());
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    if(_txtName.text.length > 0) {
      if(_txtName.text != GameData.getName()) {
        // 名前更新
        GameData.setName(_txtName.text);
        // セーブ
        GameData.save();
      }
    }

    super.destroy();
  }

  /**
   * 名前を設定
   **/
  private function _setName(name:String):Void {
    _txtName.text = name;
  }
  private function _addName(c:String):Void {
    if(_isNameMax()) {
      return;
    }

    _txtName.text += c;
  }
  private function _delName():Void {
    var length = _txtName.text.length;
    _txtName.text = _txtName.text.substr(0, length-1);
  }
  private function _isNameMax():Bool {
    return _txtName.text.length >= MAX_NAME;
  }


  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _txtTip.x = FlxG.mouse.x;
    _txtTip.y = FlxG.mouse.y-24;
    _sprTip.x = _txtTip.x;
    _sprTip.y = _txtTip.y;
    _sprTip.visible = _txtTip.visible;

    _updateInput();
#if debug
    updateDebug();
#end
  }

  /**
   * 文字入力
   **/
  private function _updateInput():Void {
    for(i in FlxKey.A...FlxKey.Z + 1) {
      if(FlxG.keys.justPressed.check(i)) {
        var c = String.fromCharCode(i).toLowerCase();
        _addName(c);
      }
    }
    for(i in FlxKey.ZERO...FlxKey.NINE+1) {
      if(FlxG.keys.justPressed.check(i)) {
        var c = String.fromCharCode(i);
        _addName(c);
      }
    }
    if(FlxG.keys.justPressed.BACKSPACE) {
      _delName();
    }
  }

  /**
   * デバッグ
   **/
  private function updateDebug():Void {

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
