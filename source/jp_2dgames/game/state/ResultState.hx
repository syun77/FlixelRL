package jp_2dgames.game.state;
import jp_2dgames.game.save.GameData;
import jp_2dgames.game.util.BgWrap;
import jp_2dgames.lib.Snd;
import flixel.addons.effects.FlxTrail;
import flash.display.BlendMode;
import flixel.util.FlxAngle;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxRandom;
import flixel.util.FlxTimer;
import jp_2dgames.game.util.Key;
import jp_2dgames.game.util.CalcScore;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;

/**
 * きらきらエフェクト
 **/
private class Kira extends FlxSprite {
  // パーティクル管理
  public static var parent:FlxTypedGroup<Kira>;

  public static function start(X:Float, Y:Float):Void {
    var k:Kira = parent.recycle();
    k.init(X, Y);
  }

  private var _timer:Int = 0;

  // コンストラクタ
  public function new() {
    super(0, 0, "assets/images/result/kira.png");
    blend = BlendMode.ADD;
    kill();
  }

  // 初期化
  public function init(X:Float, Y:Float):Void {
    x = X;
    y = Y;
    var sc = FlxRandom.floatRanged(0.2, 1);
    scale.set(sc, sc);
    var deg = FlxRandom.floatRanged(70, 110);
    var speed = FlxRandom.floatRanged(100, 400);
    velocity.x = speed * Math.cos(deg * FlxAngle.TO_RAD);
    velocity.y = speed * -Math.sin(deg * FlxAngle.TO_RAD);
    acceleration.y = 100;
    angularVelocity = FlxRandom.floatRanged(30, 100);
    angularDrag = 0.9;

    alpha = FlxRandom.floatRanged(0.3, 0.8);

    _timer = FlxRandom.intRanged(90, 150);
  }

  override public function update():Void {
    super.update();
    _timer--;
    visible = true;
    if(_timer < 30 && (_timer%30)%4 >= 2) {
      visible = false;
    }
    if(_timer < 1) {
      kill();
    }
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
  private static inline var BASE_X:Int = 80;
  private static inline var BASE_Y:Int = 32;
  private static inline var SCORE_X:Int = BASE_X + 80;
  private static inline var NEWSCORE_X:Int = SCORE_X - 32;
  private static inline var NEWSCORE_OFS_Y:Int = 4;

  // 描画オフセット
  private static inline var OFS_DY_SCORE:Int = 24;
  private static inline var OFS_DY:Int = 48;
  private static inline var OFS_DY2:Int = 48;

  // 目ぱち座標のオフセット
  private static inline var OFS_EYE_X:Int = 143;
  private static inline var OFS_EYE_Y:Int = 138;

  // スコアテキストの幅
  private static inline var SCORE_WIDTH:Int = 200;

  // テキスト
  private var _txtCaption:FlxText;
  private var _txtList:List<FlxText>;

  // 女の子
  private var _girl:FlxSprite;
  private var _eye:FlxSprite;
  private var _eye2:FlxSprite;

  private var _tEye:Int = 0;

  // 状態
  private var _state:State = State.Wait;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap(true));

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

      if(GameData.isNewHiscore()) {
        // ハイスコア更新
        var px2 = NEWSCORE_X;
        var py2 = py + NEWSCORE_OFS_Y;
        var txtNewScore = new FlxText(px2, py2, SCORE_WIDTH, "NEW!", FONT_SIZE_SCORE);
        txtNewScore.setBorderStyle(FlxText.BORDER_OUTLINE, FlxColor.WHITE, 2);

        FlxTween.color(txtNewScore, 1, FlxColor.RED, FlxColor.GOLDENROD, 1, 1, {ease:FlxEase.expoInOut, type:FlxTween.PINGPONG});

        _txtList.add(txtNewScore);
      }

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
    var sprGirl = new FlxSprite(FlxG.width, 0, "assets/images/result/girl.png");
    var trail = new FlxTrail(sprGirl);
    this.add(trail);
    this.add(sprGirl);
    var girlX = FlxG.width-sprGirl.width-80;
    FlxTween.tween(sprGirl, {x:girlX}, 1, {ease:FlxEase.expoOut});
    _girl = sprGirl;

    new FlxTimer(1.5, function(timer:FlxTimer) {
      // メイン処理へ
      Snd.playMusic("result");
      _state = State.Main;
    });

    // 目ぱち
    var sprEye = new FlxSprite(girlX + OFS_EYE_X, OFS_EYE_Y, "assets/images/result/girl2.png");
    this.add(sprEye);
    sprEye.visible = false;
    _eye = sprEye;
    var sprEye2 = new FlxSprite(girlX + OFS_EYE_X, OFS_EYE_Y, "assets/images/result/girl3.png");
    this.add(sprEye2);
    sprEye2.visible = false;
    _eye2 = sprEye2;

    // 光エフェクト
    Kira.parent = new FlxTypedGroup<Kira>(64);
    for(i in 0...Kira.parent.maxSize) {
      var k = new Kira();
      Kira.parent.add(k);
    }
    this.add(Kira.parent);

    Snd.playSe("chime");

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    Kira.parent = null;

    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Wait:
        // ちょっと待つ
      case State.Main:

        // キラキラエフェクト出現
        if(FlxRandom.chanceRoll(10)) {
          var px = FlxRandom.floatRanged(FlxG.width/2, FlxG.width/2+256);
          var py = FlxRandom.floatRanged(FlxG.height/3, FlxG.height/3+128);
          Kira.start(px, py);
        }

        // 目ぱち更新
        _tEye += FlxRandom.intRanged(1, 5);
        _eye.visible = false;
        _eye2.visible = false;
        if(_tEye%1000 < 16) {
          _eye.visible = true;
        }
        else if(_tEye%1000 < 32) {
          _eye2.visible = true;
        }
        else if(_tEye%1000 < 48) {
          _eye.visible = true;
        }

        if(Key.press.A) {
          // フェードアウト開始
          Snd.stopMusic();
          _state = State.FadeOut;
          _eye.visible = false;
          _eye2.visible = false;
        }
      case State.FadeOut:

        // テキスト追い出し
        FlxTween.tween(_txtCaption, {y:-64}, 1, {ease:FlxEase.expoOut});
        for(txt in _txtList) {
          FlxTween.tween(txt, {x:-480}, 1, {ease:FlxEase.expoOut});
        }
        FlxTween.tween(_girl, {x:FlxG.width}, 1, {ease:FlxEase.expoOut});

        // 白フェード
        FlxG.camera.fade(FlxColor.WHITE, 1, false, function() {
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
