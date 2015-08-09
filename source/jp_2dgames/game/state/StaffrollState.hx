package jp_2dgames.game.state;
import flixel.tweens.FlxEase;
import flixel.util.FlxRandom;
import jp_2dgames.game.util.DirUtil;
import jp_2dgames.game.event.EventNpc;
import jp_2dgames.game.util.Key;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import jp_2dgames.lib.CsvLoader;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import jp_2dgames.lib.CsvLoader;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;

/**
 * スタッフロール画面
 **/
class StaffrollState extends FlxState {

  // CSVデータ
  private var _csv:CsvLoader;
  // メッセージ番号
  private var _idx:Int = 0;
  // テキスト生存数
  private var _cntText:Int = 0;

  private var _npcs:Array<EventNpc>;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景画像読み込み
    var sprGirl = new FlxSprite(FlxG.width, 0, "assets/images/result/girl.png");
    sprGirl.x = FlxG.width-sprGirl.width-80;
    this.add(sprGirl);
    FlxTween.color(sprGirl, 1, FlxColor.BLACK, FlxColor.CHARCOAL, 1, 1, {ease:FlxEase.sineIn});

    _npcs = new Array<EventNpc>();
    // プレイヤー表示
    var player = new EventNpc();
    player.revive();
    player.setHit(false);
    player.init("player", -12, 11, Dir.Right);
    player.requestMove(Dir.Right, 12 + 1);
    player.requestDir(Dir.Down);
    this.add(player);
    _npcs.push(player);

    // ネコ
    for(i in 0...4) {
      var cat = new EventNpc();
      cat.revive();
      cat.setHit(false);
      var px:Int = -12 * i - 36 + FlxRandom.intRanged(0, 8);
      var dx:Int = -px + 2 + i;
      cat.init("cat", px, 11, Dir.Right);
      cat.requestMove(Dir.Right, dx);
      cat.requestDir(Dir.Down);
      switch(i) {
        case 0: cat.color = 0xfffa8072;
        case 1: cat.color = 0xFF80A0FF;
        case 2: cat.color = 0xffffffff;
        case 3: cat.color = 0xffbfff00;
      }
      this.add(cat);
      _npcs.push(cat);
    }

    // テキスト読み込み
    _csv = new CsvLoader("assets/data/staffroll.csv");
    _idx = 1;
    _appearText(null);
  }

  /**
   * テキスト出現
   **/
  private function _appearText(timer:FlxTimer):Void {

    // 座標
    var px = FlxG.width/3.5;
    var py = FlxG.height;
    // テキスト生成
    var txt = new FlxText(px, py, 640);
    txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    txt.text = _csv.getString(_idx, "msg");
    txt.color = FlxColor.WHITE;
    this.add(txt);
    // 生成カウンタアップ
    _cntText++;
    FlxTween.tween(txt, {y:-24}, 16, {ease:function(t:Float) { return t; }, complete:function(tween:FlxTween) {
      // 生成カウンタを下げる
      _cntText--;
      this.remove(txt);
    }});
    _idx++;
    if(_csv.hasId(_idx)) {
      // テキストデータがあれば再帰
      new FlxTimer(1, _appearText);
    }
    else {
      // おしまい
      var idx = 0;
      for(npc in _npcs) {
        if(idx != 0) {
          npc.requestWait(2);
        }
        npc.requestMove(Dir.Right, 100);
        idx++;
      }
    }
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

    if(_cntText <= 0 || Key.press.A) {
      // おしまい
      FlxG.switchState(new TitleState());
    }
  }
}
