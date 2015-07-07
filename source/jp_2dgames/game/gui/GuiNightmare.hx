package jp_2dgames.game.gui;
import jp_2dgames.game.actor.Enemy;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

/**
 * ナイトメア管理
 **/
class GuiNightmare extends FlxSpriteGroup {

  // 基準座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 384 + 8;

  // 背景のサイズ
  private static inline var WIDTH = 212 - 8*2;
  private static inline var HEIGHT = 64 + 8*2;

  // 標示物の座標
  private static inline var INFO_X = 8;
  private static inline var INFO_Y = 8;
  private static inline var TURN_X = 8;
  private static inline var TURN_Y = INFO_Y+24;
  private static inline var SKILL_X = 8;
  private static inline var SKILL_Y = TURN_Y+24;

  // 残りターン数
  private var _turnLimit:Int;

  // テキスト
  private var _txtInfo:FlxText; // 名前
  private var _txtTurn:FlxText; // 残りターン数
  private var _txtSkill:FlxText; // スキル

  // 点滅タイマー
  private var _tBlink:Int = 0;

  // ナイトメアの敵ID
  private var _eid:Int = -1;

  /**
   * コンストラクタ
   **/
  public function new() {
    super(POS_X, POS_Y);

    // 背景
    var sprBg = new FlxSprite(0, 0).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    sprBg.color = FlxColor.GRAY;
    sprBg.alpha = 0.4;
    this.add(sprBg);

    // キャプション
    _txtInfo = new FlxText(INFO_X, INFO_Y, 0, 160);
    _txtInfo.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtInfo);

    // ターン数のテキスト
    _txtTurn = new FlxText(TURN_X, TURN_Y, 0, 160);
    _txtTurn.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtTurn);

    // スキルテキスト
    _txtSkill = new FlxText(SKILL_X, SKILL_Y, 0, 160);
    _txtSkill.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtSkill);

    _turnLimit = 0;
  }

  /**
   * ターン数を設定する
   **/
  public function setTurn(turnCount:Int):Void {
    if(_turnLimit != turnCount) {
      // 値が前回と違っていたら更新
      _turnLimit = turnCount;
      _txtTurn.text = '残り${turnCount}ターン';

    }
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    setTurn(Global.getTurnLimitNightmare());

    var eid = NightmareMgr.getEnemyID();
    if(_eid != eid) {
      // 別のナイトメアになったので名前を更新
      _eid = eid;
      var name = Enemy.getNameFromID(_eid);
      _txtInfo.text = name;
      // スキル名を設定
      var skill = NightmareMgr.getSkillName();
      _txtSkill.text = skill;
    }

    _tBlink++;
    _txtTurn.color = FlxColor.WHITE;
    if(_turnLimit < 10) {
      if(_tBlink%32 < 16) {
        // 文字を赤くする
        _txtTurn.color = FlxColor.CRIMSON;
      }
    }

    // スキル
    if(NightmareMgr.Exists()) {
      _txtSkill.color = FlxColor.YELLOW;
    }
    else {
      _txtSkill.color = FlxColor.GRAY;
    }
  }
}
