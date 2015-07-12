package jp_2dgames.game.gui;
import jp_2dgames.game.state.PlayState;
import flixel.group.FlxSpriteGroup;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;

/**
 * ステータス表示・詳細
 **/
class GuiStatusDetail extends FlxSpriteGroup {
  // 背景の枠
  private static inline var BG_WIDTH = 200;
  private static inline var BG_HEIGHT = 100;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = 16;
  // 力
  private static inline var STR_X = MSG_X;
  private static inline var STR_Y = 8;
  // 体力
  private static inline var VIT_X = MSG_X + 72;
  private static inline var VIT_Y = STR_Y;
  // 攻撃力
  private static inline var ATK_X = MSG_X;
  private static inline var ATK_Y = VIT_Y + 32;
  // 守備力
  private static inline var DEF_X = MSG_X;
  private static inline var DEF_Y = ATK_Y + 24;

  // パラメータテキスト
  private var _txtStr:FlxText; // Str
  private var _txtVit:FlxText; // Vit
  private var _txtAtk:FlxText; // Atk
  private var _txtDef:FlxText; // Def

  private var _orgY:Float = 0;

  /**
   * 差分文字の作成
   **/
  private function _getDiffString(v:Int):String {
    if(v == 0) {
      return "";
    }
    var str = ' (${v})';
    if(v > 0) {
      str = ' (+${v})';
    }
    return str;
  }
  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    _orgY = Y;
    super(X, Y);

    // 背景
    var back = new FlxSprite(0, 0, "assets/images/ui/window200x100.png");
    back.color = Reg.COLOR_DETAIL_FRAME;
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

  private function _updateText(item:ItemData):Void {

    var player = cast(FlxG.state, PlayState).player;
    var atk = player.atk;
    var def = player.def;
    // 装備品であればそのパラメータを反映
    switch(item.type) {
      case IType.Weapon:
        atk = ItemUtil.getAtk(item);
      case IType.Armor:
        def = ItemUtil.getDef(item);
      default:
    }


    // 力
    _txtStr.text = '力: ${player.getStr()}';
    // 体力
    _txtVit.text = '耐久力: ${player.getVit()}';
    // 攻撃力
    _txtAtk.text = '攻撃力: ${atk}';
    _txtAtk.color = FlxColor.WHITE;
    // 守備力
    _txtDef.text = '守備力: ${def}';
    _txtDef.color = FlxColor.WHITE;

    var itemid = item.id;
    var type = item.type;
    if(type == IType.None) {
      // 無効なアイテムなので何もしない
      return;
    }
    if(ItemUtil.isEquip(itemid) == false) {
      // 装備できないアイテムなので何もしない
      return;
    }
    switch(type) {
      case IType.Weapon:
        var now = player.atk;
        var next = ItemUtil.getAtk(item);
        _setDiffText(_txtAtk, next - now);
      case IType.Armor:
        var now = player.def;
        var next = ItemUtil.getDef(item);
        _setDiffText(_txtDef, next - now);
      case IType.Ring:
      case IType.Food:
      case IType.Money:
      case IType.None:
      case IType.Potion:
      case IType.Scroll:
      case IType.Wand:
      case IType.Orb:
    }
  }

  /**
   * 差分テキストの更新
   **/
  private function _setDiffText(txt:FlxText, v:Int):Void {
    txt.text += _getDiffString(v);
    if(v > 0) {
      // パラメータ増加
      txt.color = FlxColor.MAUVE;
    }
    else if(v < 0) {
      // パラメータ減少
      txt.color = FlxColor.AQUAMARINE;
    }
  }

  /**
   * 更新
   **/
  override public function update() {
    super.update();
  }

  /**
   * 表示する
   **/
  public function show(item:ItemData) {
    _updateText(item);
  }

  /**
   * 選択中のアイテムを設定する
   **/
  public function setSelectedItem(item:ItemData) {
    _updateText(item);
  }
}
