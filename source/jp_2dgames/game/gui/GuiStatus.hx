package jp_2dgames.game.gui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * ステータス表示
 **/
class GuiStatus extends FlxGroup {

  /**
   * ヘルプモード
   **/
  public static inline var HELP_NONE:Int = 0; // 非表示
  public static inline var HELP_KEYINPUT:Int = 1; // 通常移動
  public static inline var HELP_INVENTORY:Int = 2; // インベントリ
  public static inline var HELP_DIALOG_YN:Int = 3; // Yes/Noダイアログ

  // ステータス表示座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 4;

  // バーのサイズ
  private static inline var BAR_W = 180;
  private static inline var BAR_H = 4;

  // フロア数
  private static inline var FLOORTEXT_X = POS_X;
  private static inline var FLOORTEXT_Y = POS_Y;
  // レベルテキスト
  private static inline var LVTEXT_X = POS_X + 48;
  private static inline var LVTEXT_Y = POS_Y;
  // 所持金
  private static inline var MONEYTEXT_X = POS_X + 112;
  private static inline var MONEYTEXT_Y = POS_Y;
  // HPテキスト
  private static inline var HPTEXT_X = POS_X;
  private static inline var HPTEXT_Y = FLOORTEXT_Y + 24;
  // HPバー
  private static inline var HPBAR_X = POS_X;
  private static inline var HPBAR_Y = HPTEXT_Y + 24;
  // 満腹度
  private static inline var FULLTEXT_X = POS_X;
  private static inline var FULLTEXT_Y = HPBAR_Y + 8;
  // ヘルプテキスト
  private static inline var HELP_X = 32;
  private static inline var HELP_DY = 24;

  private var _txtLv:FlxText;
  private var _txtFloor:FlxText;
  private var _txtHp:FlxText;
  private var _hpBar:FlxBar;
  private var _txtFull:FlxText;
  private var _txtMoney:FlxText;
  private var _bgHelp:FlxSprite;
  private var _txtHelp:FlxText;
  private var _helpY:Float;
  private var _txtHelpOfsY:Float = 0;
  private var _helpMode:Int = HELP_NONE;
  public var helpmode(get, never):Int;
  private function get_helpmode() {
    return _helpMode;
  }

  /**
	 * コンストラクタ
	 **/
  public function new() {
    super();

    // フロアテキスト
    _txtFloor = new FlxText(FLOORTEXT_X, FLOORTEXT_Y, 128);
    _txtFloor.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtFloor);

    // レベルテキスト
    _txtLv = new FlxText(LVTEXT_X, LVTEXT_Y, 128);
    _txtLv.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtLv);

    // HPテキスト
    _txtHp = new FlxText(HPTEXT_X, HPTEXT_Y, 180);
    _txtHp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtHp);

    // HPバー
    _hpBar = new FlxBar(HPBAR_X, HPBAR_Y, FlxBar.FILL_LEFT_TO_RIGHT, BAR_W, BAR_H);
    _hpBar.createFilledBar(FlxColor.CRIMSON, FlxColor.CHARTREUSE);
    this.add(_hpBar);

    // 満腹度テキスト
    _txtFull = new FlxText(FULLTEXT_X, FULLTEXT_Y, 160);
    _txtFull.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtFull);

    // 所持金テキスト
    _txtMoney = new FlxText(MONEYTEXT_X, MONEYTEXT_Y, 128);
    _txtMoney.alignment = "right"; // 右寄せ
    _txtMoney.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txtMoney);

    // ヘルプ座標(Y)
    _helpY = FlxG.height - HELP_DY;
    // ヘルプの背景
    _bgHelp = new FlxSprite(0, _helpY).makeGraphic(FlxG.width, HELP_DY, FlxColor.BLACK);
    _bgHelp.alpha = 0.7;
    this.add(_bgHelp);
    // ヘルプテキスト
    _txtHelp = new FlxText(HELP_X, FlxG.height, 600);
    _txtHelp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtHelp);

    // ヘルプテキスト設定
    changeHelp(HELP_KEYINPUT);
  }

  /**
	 * 更新
	 **/
  override public function update() {
    super.update();

    // フロア数
    var floor = Global.getFloor();
    _txtFloor.text = '${floor}F';

    var player = cast(FlxG.state, PlayState).player;
    var lv = player.params.lv;
    // レベル
    _txtLv.text = 'LV:${lv}';

    // HP
    var hp = player.params.hp;
    var hpmax = player.params.hpmax;
    _txtHp.text = 'HP: ${hp}/${hpmax}';
    _hpBar.percent = 100 * hp / hpmax;

    // 満腹度
    var full = player.food;
    var fullmax = player.foodmax;
    _txtFull.text = '満腹度: ${full}/${fullmax}';

    // 所持金
    var money = Global.getMoney();
    _txtMoney.text = '${money}円';

    // ヘルプテキストのアニメーション
    _txtHelpOfsY *= 0.8;
    _txtHelp.y = _helpY + _txtHelpOfsY;
  }

  public function changeHelp(mode:Int) {
    if(_helpMode == mode) {
      // 変更不要
      return;
    }

    _helpMode = mode;
    var text = "";
    switch(_helpMode) {
      case HELP_NONE:
        // 非表示
      case HELP_KEYINPUT:
        text = "カーソルキー:移動 / Z:攻撃 / X:メニュー / C+カーソルキー:振り向く";
      case HELP_INVENTORY:
        text = "カーソルキー:項目の移動 / Z:選択 / X:キャンセル";
      case HELP_DIALOG_YN:
        text = "カーソルキー:項目の移動 / Z:決定";
    }

    _txtHelp.text = text;
    _txtHelp.y = FlxG.height;

    // アニメーション開始
    _txtHelpOfsY = HELP_DY;
  }
}
