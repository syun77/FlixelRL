package jp_2dgames.game.state;
import jp_2dgames.game.GameData;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxButtonPlus;
import jp_2dgames.game.util.NameGenerator;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void) {
    var w = 160; // ボタンの幅
    var h = 32;  // ボタンの高さ
    var s = 16;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;
  }
}

/**
 * 名前入力画面
 **/
class NameEntryState extends FlxState {

  // 名前に設定可能な最大文字数
  private static inline var MAX_NAME:Int = 8;

  // 名前テキストの座標
  private static inline var NAME_X = 128;
  private static inline var NAME_Y = 128;
  private static inline var NAME_W = 256;

  // 消去ボタン
  private static inline var CLEAR_X = 60;
  private static inline var CLEAR_Y = 180;

  // 自動入力ボタン
  private static inline var MALE_X = 60;
  private static inline var MALE_Y = 260;
  private static inline var FEMALE_X = MALE_X + 200;
  private static inline var FEMALE_Y = MALE_Y;

  // 戻る
  private static inline var BACK_X = 60;
  private static inline var BACK_Y = 400;

  // 名前自動生成
  private var _generator:NameGenerator;
  // 名前テキスト
  private var _txtName:FlxText;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    _generator = new NameGenerator();
    _txtName = new FlxText(NAME_X, NAME_Y, NAME_W, "", 24);
    this.add(_txtName);

    // 名前消去
    this.add(new MyButton(CLEAR_X, CLEAR_Y, "CLEAR", function() {
      _setName("");
    }));

    // 自動入力（男性）
    this.add(new MyButton(MALE_X, MALE_Y, "MALE", function() {
      _setName(_generator.getMale());
    }));

    // 自動入力（女性）
    this.add(new MyButton(FEMALE_X, FEMALE_Y, "FEMALE", function() {
      _setName(_generator.getFemale());
    }));

    // 戻るボタン
    this.add(new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new TitleState());
    }));

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
