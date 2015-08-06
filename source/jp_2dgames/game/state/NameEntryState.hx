package jp_2dgames.game.state;
import jp_2dgames.lib.Snd;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSubState;
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
 * 名前入力画面
 **/
class NameEntryState extends FlxSubState {

  // 名前に設定可能な最大文字数
  private static inline var MAX_NAME:Int = 8;

  // 基準座標
  private static inline var BASE_X = 128;
  private static inline var BASE_Y = 64;

  // ヘルプテキスト
  private static inline var HELP_OFS_X = 224;
  private static inline var HELP_Y = 32;

  // 名前テキストの座標
  private static inline var NAME_X = 128;
  private static inline var NAME_Y = HELP_Y+64;
  private static inline var NAME_W = 160;

  // 消去ボタン
  private static inline var CLEAR_X = NAME_X + 180;
  private static inline var CLEAR_Y = NAME_Y;

  // 自動入力ボタン
  private static inline var MALE_X = 112;
  private static inline var MALE_Y = NAME_Y+64;
  private static inline var FEMALE_X = MALE_X + 200;
  private static inline var FEMALE_Y = MALE_Y;

  // 戻る
  private static inline var BACK_X = 0;
  private static inline var BACK_Y = MALE_Y+64;

  // 名前自動生成
  private var _generator:NameGenerator;

  // 描画グループ
  private var _group:FlxSpriteGroup;
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

    // 画面サイズ
    var width  = FlxG.width  - (BASE_X*2);
    var height = 288;

    _group = new FlxSpriteGroup(BASE_X, BASE_Y);

    // 背景
    var bg = new FlxSprite(0, 0).makeGraphic(width, height, FlxColor.GRAY);
    {
      var w = bg.width;
      var h = bg.height;
      var fSize = 4; // 枠の幅
      var rect = new Rectangle(fSize, fSize, w-fSize*2, h-fSize*2);
      bg.pixels.fillRect(rect, FlxColor.BLACK);
      bg.dirty = true;
      bg.updateFrameData();
    }
    bg.alpha = 0;
    _group.add(bg);
    FlxTween.tween(bg, {alpha:0.8}, 1, {ease:FlxEase.expoOut});

    // CSVテキスト
    _csv = new CsvLoader("assets/data/nameentry.csv");

    // 名前説明
    {
      var msg = _csv.getString(1, "msg");
      _txtHelp = new FlxText(width/2-HELP_OFS_X, HELP_Y, 480, msg);
      _txtHelp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      _group.add(_txtHelp);
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
    FlxTween.color(_sprName, 1, FlxColor.SILVER, FlxColor.WHITE, 1, 1, {type:FlxTween.PINGPONG, ease:FlxEase.sineInOut});
    _group.add(_sprName);

    // 名前入力
    _txtName = new FlxText(NAME_X, NAME_Y, NAME_W, "", 24);
    _group.add(_txtName);

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
    _group.add(new MyButton(CLEAR_X, CLEAR_Y, "CLEAR", function() {
      _setName("");
      Snd.playSe("equip", true);
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(2, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    // 自動入力（男性）
    _group.add(new MyButton(MALE_X, MALE_Y, "MALE", function() {
      _setName(_generator.getMale());
      Snd.playSe("equip", true);
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(3, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    // 自動入力（女性）
    _group.add(new MyButton(FEMALE_X, FEMALE_Y, "FEMALE", function() {
      _setName(_generator.getFemale());
      Snd.playSe("equip", true);
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(4, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    // 戻るボタン
    _group.add(new MyButton(width/2-160/2, BACK_Y, "BACK", function() {
      Snd.playSe("hint", true);
      // 自身を閉じる
      close();
    }, function() {
      _txtTip.visible = true;
      _txtTip.text = _csv.getString(5, "msg");
      Snd.playSe("pi", true);
    }, function() {
      _txtTip.visible = false;
    }));

    _group.add(_sprTip);
    _group.add(_txtTip);

    this.add(_group);
    // スライド表示
    _group.y -= FlxG.height;
    FlxTween.tween(_group, {y:BASE_Y}, 1, {ease:FlxEase.expoOut});

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

    _txtTip.x = FlxG.mouse.x+16;
    _txtTip.y = FlxG.mouse.y-24;
    _sprTip.x = _txtTip.x;
    _sprTip.y = _txtTip.y;
    _sprTip.visible = _txtTip.visible;

    _updateInput();

    if(FlxG.keys.justPressed.ENTER) {
      // 閉じる
      Snd.playSe("hint", true);
      close();
    }

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
