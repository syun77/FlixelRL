package jp_2dgames.game.state;
import flixel.tile.FlxTile;
import flixel.util.FlxTimer;
import jp_2dgames.game.util.Key;
import jp_2dgames.game.util.CalcScore;
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
 * 状態
 **/
private enum State {
  Wait;    // ちょっつ待つ
  Main;    // メイン
  FadeOut; // フェードアウト
  End;     // おしまい
}

/**
 * リザルト画面
 **/
class ResultState extends FlxState {

  // フォントサイズ
  private static inline var FONT_SIZE_SCORE:Int = 16;
  private static inline var FONT_SIZE:Int = 24;
  private static inline var FONT_SIZE_BIG:Int = 32;

  // 基準座標
  private static inline var BASE_X:Int = 48;
  private static inline var BASE_Y:Int = 32;
  private static inline var SCORE_X:Int = 128;

  // 描画オフセット
  private static inline var OFS_DY_SCORE:Int = 24;
  private static inline var OFS_DY:Int = 48;
  private static inline var OFS_DY2:Int = 48;

  // スコアテキストの幅
  private static inline var SCORE_WIDTH:Int = 200;

  // 背景
  private var _bgList:List<FlxSprite>;
  private var _bgCntX:Int;
  private var _bgCntY:Int;

  // テキスト
  private var _txtCaption:FlxText;
  private var _txtList:List<FlxText>;

  // 女の子
  private var _girl:FlxSprite;

  // 状態
  private var _state:State = State.Wait;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景

    _bgList = new List<FlxSprite>();
    {
      var size = Field.GRID_SIZE * 2;
      var cntX = Std.int(FlxG.width / size) + 2;
      var cntY = Std.int(FlxG.height/ size) + 2;
      _bgCntX = cntX - 1;
      _bgCntY = cntY - 1;

      // 転送領域の作成
      for(j in 0...cntY) {
        for(i in 0...cntX) {
          var px = i * size;
          var py = j * size;
          var bg = new FlxSprite(px, py, "assets/levels/tilenone.png");
          var speed = 64 / 60 * -50;
          bg.velocity.set(speed, speed);
          bg.scale.set(2, 2);
          FlxTween.color(bg, 2, FlxColor.BLACK, FlxColor.SILVER, 1, 1, {ease:FlxEase.expoOut});
          this.add(bg);
          _bgList.add(bg);
        }
      }
    }

    // キャプション
    var px = BASE_X;
    var py = BASE_Y;
    _txtCaption = new FlxText(px-16, py, 480, "GAME RANKING", FONT_SIZE_BIG);
    _txtCaption.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.GOLDENROD, 4);

    this.add(_txtCaption);

    _txtList = new List<FlxText>();

    py += OFS_DY;
    // スコア
    {
      // キャプション
      var txtScore = new FlxText(px, py, 480, 'Score', FONT_SIZE);
      _txtList.add(txtScore);

      px = SCORE_X;
      py += OFS_DY2;
      // 経験値
      var scExp = CalcScore.getExp();
      var txtExp = new FlxText(px, py, SCORE_WIDTH, 'Exp:', FONT_SIZE_SCORE);
      _txtList.add(txtExp);
      var txtScExp = new FlxText(px, py, SCORE_WIDTH, '${scExp}pt', FONT_SIZE_SCORE);
      txtScExp.alignment = "right";
      _txtList.add(txtScExp);
      // お金
      py += OFS_DY_SCORE;
      var scMoney = CalcScore.getMoeny();
      var txtMoney = new FlxText(px, py, SCORE_WIDTH, 'Money:', FONT_SIZE_SCORE);
      _txtList.add(txtMoney);
      var txtScMoney = new FlxText(px, py, SCORE_WIDTH, '${scMoney}pt', FONT_SIZE_SCORE);
      txtScMoney.alignment = "right";
      _txtList.add(txtScMoney);
      // アイテム
      py += OFS_DY_SCORE;
      var scInventory = CalcScore.getInventory();
      var txtInventory = new FlxText(px, py, SCORE_WIDTH, 'Item:', FONT_SIZE_SCORE);
      _txtList.add(txtInventory);
      var txtScInventory = new FlxText(px, py, SCORE_WIDTH, '${scInventory}pt', FONT_SIZE_SCORE);
      txtScInventory.alignment = "right";
      _txtList.add(txtScInventory);
      // トータル
      py += OFS_DY_SCORE;
      var score = Global.getScore();
      var txtScore = new FlxText(px, py, SCORE_WIDTH, '${score}pt', FONT_SIZE);
      txtScore.alignment = "right";
      _txtList.add(txtScore);
    }

    px = BASE_X;
    py += OFS_DY;
    // 到達階
    var floor = Global.getFloor();
    var txtFloor = new FlxText(px, py, 480, 'Floor: ${floor}', FONT_SIZE);
    _txtList.add(txtFloor);

    py += OFS_DY;
    // ランク
    var rank = "Dragon Master";
    var txtFloor = new FlxText(px, py, 480, 'Rank: ${rank}', FONT_SIZE);
    _txtList.add(txtFloor);

    var idx = 0;
    for(txt in _txtList) {
      this.add(txt);
      txt.x -= 480;
      FlxTween.tween(txt, {x:txt.x+480}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.1});
      idx++;
    }

    // 女の子
    var sprGirl = new FlxSprite(FlxG.width, 0, "assets/images/result.png");
    this.add(sprGirl);
    FlxTween.tween(sprGirl, {x:FlxG.width/2}, 1, {ease:FlxEase.expoOut});
    _girl = sprGirl;

    new FlxTimer(1.5, function(timer:FlxTimer) {
      _state = State.Main;
    });
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

    // 背景更新
    for(bg in _bgList) {
      if(bg.x < -bg.width*2) {
        bg.x += bg.width*2 * (_bgCntX + 1);
      }
      if(bg.y < -bg.height*2) {
        bg.y += bg.height*2 * (_bgCntY + 1);
      }
    }

    switch(_state) {
      case State.Wait:
        // ちょっと待つ
      case State.Main:
        if(Key.press.A) {
          _state = State.FadeOut;
        }
      case State.FadeOut:
        // テキスト追い出し
        FlxTween.tween(_txtCaption, {y:-64}, 1, {ease:FlxEase.expoOut});
        for(txt in _txtList) {
          FlxTween.tween(txt, {x:-480}, 1, {ease:FlxEase.expoOut});
        }
        FlxTween.tween(_girl, {x:FlxG.width}, 1, {ease:FlxEase.expoOut});

        FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
          // タイトル画面に戻る
          FlxG.switchState(new TitleState());
        });
        _state = State.End;
      case State.End:
        // 終了待ち
    }


    #if neko
    if(FlxG.keys.justPressed.R) {
      FlxG.resetState();
    }
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
    #end
  }

}
