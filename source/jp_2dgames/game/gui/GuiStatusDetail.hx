package jp_2dgames.game.gui;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * ステータス表示・詳細
 **/
class GuiStatusDetail extends FlxGroup {
  // 基準座標
  private static inline var POS_X = 200;
  private static inline var POS_Y = 200;

  // 背景の枠
  private static inline var BG_WIDTH = 200;
  private static inline var BG_HEIGHT = 100;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = POS_X + 16;
  // 力
  private static inline var STR_X = MSG_X;
  private static inline var STR_Y = POS_Y + 8;
  // 体力
  private static inline var VIT_X = MSG_X;
  private static inline var VIT_Y = STR_Y + 16;
  // 攻撃力
  private static inline var ATK_X = MSG_X;
  private static inline var ATK_Y = VIT_Y + 16;
  // 守備力
  private static inline var DEF_X = MSG_X;
  private static inline var DEF_Y = ATK_Y + 24;

  private var _txtStr:FlxText;
  private var _txtVit:FlxText;
  private var _txtAtk:FlxText;
  private var _txtDef:FlxText;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 背景
    var back = new FlxSprite(POS_X, POS_Y).makeGraphic(BG_WIDTH, BG_HEIGHT, FlxColor.BLACK);
    back.alpha = 0.5;
    this.add(back);

    // 力テキスト
    _txtStr = new FlxText(STR_X, STR_Y, TXT_WIDTH);
    _txtStr.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtStr);

    // 体力テキスト
    _txtVit = new FlxText(VIT_X, VIT_Y, TXT_WIDTH);
    _txtVit.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
//    this.add(_txtVit);

    // 攻撃力テキスト
    _txtAtk = new FlxText(ATK_X, ATK_Y, TXT_WIDTH);
    _txtAtk.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtAtk);

    // 守備力テキスト
    _txtDef = new FlxText(DEF_X, DEF_Y, TXT_WIDTH);
    _txtDef.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtDef);
  }

  /**
   * 更新
   **/
  override public function update() {
    super.update();

    var player = cast(FlxG.state, PlayState).player;

    // 力
    _txtStr.text = '力: ${player.params.str}';
    // 体力
    _txtVit.text = '体力: ${player.params.vit}';
    // 攻撃力
    _txtAtk.text = '攻撃力: ${player.atk}';
    // 守備力
    _txtDef.text = '守備力: ${player.def}';
  }
}
