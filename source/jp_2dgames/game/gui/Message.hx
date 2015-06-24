package jp_2dgames.game.gui;
import jp_2dgames.lib.CsvLoader;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * メッセージ定数
 **/
class Msg {
  public static inline var PLAYER_DAMAGE:Int = 1; // プレイヤーダメージ
  public static inline var ENEMY_DAMAGE:Int = 2; // 敵ダメージ
  public static inline var ENEMY_DEFEAT:Int = 3; // 敵を倒した
  public static inline var ITEM_DISCARD:Int = 4; // アイテムを捨てた
  public static inline var ITEM_EAT:Int = 5; // アイテムを食べた
  public static inline var ITEM_EQUIP:Int = 6; // アイテムを装備した
  public static inline var ITEM_UNEQUIP:Int = 7; // アイテムを外した
  public static inline var ITEM_PICKUP:Int = 8; // アイテムを拾った
  public static inline var MISS:Int = 9; // 攻撃を外した
  public static inline var LEVELUP:Int = 10; // レベルアップした
  public static inline var LEVELUP2:Int = 11; // レベル数値を表示
  public static inline var ITEM_FULL:Int = 12; // アイテムがいっぱい
  public static inline var ITEM_STEPON:Int = 13; // アイテムの上に乗る
  public static inline var ITEM_PUT:Int = 14; // アイテムを床に置いた
  public static inline var INVENTORY_CANT_OPEN:Int = 15; // インベントリを開けない
  public static inline var ITEM_DESTORY:Int = 16; // アイテムが壊れた
  public static inline var ITEM_HIT_WALL:Int = 17; // アイテムが壁に当たった
  public static inline var ITEM_THROW:Int = 18; // アイテムを投げた
  public static inline var RECOVER_HP:Int = 19; // HP回復
  public static inline var ITEM_DRINK:Int = 20; // アイテムを飲んだ
  public static inline var RECOVER_FOOD_MAX:Int = 21; // 満腹度が最大まで回復した
  public static inline var RECOVER_FOOD:Int = 22; // 満腹度が最大まで回復した
  public static inline var ITEM_SCROLL:Int = 23; // 巻物を読んだ
  public static inline var GROW_HPMAX:Int = 24; // 最大HP上昇
  public static inline var GROW_FOOD:Int = 25; // 最大満腹度上昇
  public static inline var GROW_STR:Int = 26; // 力上昇
  public static inline var BAD_CONFUSION:Int = 27; // 混乱
  public static inline var BAD_SLEEP:Int = 28; // 眠り
  public static inline var BAD_PARALYSIS:Int = 29; // 麻痺
  public static inline var BAD_SICKNESS:Int = 30; // 病気
  public static inline var BAD_POWERFUL:Int = 31; // 元気いっぱい
  public static inline var BAD_AnGER:Int = 32; // 怒り
  public static inline var BAD_POISON:Int = 33; // 毒

  // メニュー
  public static inline var MENU_USE:Int = 48; // メニュー: 使う
  public static inline var MENU_EQUIP:Int = 49; // メニュー: 装備
  public static inline var MENU_UNEQUIP:Int = 50; // メニュー: 外す
  public static inline var MENU_THROW:Int = 51; // メニュー: 投げる
  public static inline var MENU_PUT:Int = 52; // メニュー: 置く
  public static inline var MENU_CHANGE:Int = 53; // メニュー: 交換
  public static inline var MENU_PICKUP:Int = 54; // メニュー: 拾う
  public static inline var MENU_NEXTFLOOR_MSG:Int = 55; // メニュー: 歓談がある
  public static inline var MENU_NEXTFLOOR:Int = 56; // メニュー: 下りる
  public static inline var MENU_STAY:Int = 57; // メニュー: そのまま

  // ページ
  public static inline var PAGE_FEET:Int = 64; // 足下
  public static inline var PAGE_NOITEM:Int = 65; // 何も持っていない

  // ヘルプ
  public static inline var HELP_KEYINPUT:Int = 72; // ヘルプ: 通常
  public static inline var HELP_INVENCTORY:Int = 73; // ヘルプ: インベントリ
  public static inline var HELP_DIALOG:Int = 74; // ヘルプ: ダイアログ
  public static inline var HELP_INVENCTORYCOMMAND:Int = 75; // ヘルプ: インベントリ・コマンド
}

/**
 * メッセージウィンドウ
 **/
class Message extends FlxGroup {

  // メッセージログの最大
  private static inline var MESSAGE_MAX = 3;//5;
  // ウィンドウ座標
  private static inline var POS_X = 8;
  private static inline var POS_Y = 480 - HEIGHT - 24 - 8;
  private static inline var POS_Y2 = 24 + 8;
  // ウィンドウサイズ
  private static inline var WIDTH = 640 - 8 * 2;
  private static inline var HEIGHT = (MESSAGE_MAX*DY)+14;//160 - 8 * 2;
  private static inline var MSG_POS_X = 8;
  private static inline var MSG_POS_Y = 8;
  // メッセージ表示間隔
  private static inline var DY = 26;

  // ウィンドウが消えるまでの時間 (5sec)
  private static inline var TIMER_DISAPPEAR:Float = 5;

  // インスタンス
  public static var instance:Message = null;

  // メッセージの追加
  public static function push(msg:String) {
    Message.instance._push(msg);
  }

  public static function push2(msgId:Int, args:Array<Dynamic>=null) {
    Message.instance._push2(msgId, args);
  }

  // ヒントメッセージの追加
  public static function pushHint() {
    return Message.instance._pushHint();
  }

  // メッセージの取得
  public static function getText(msgId:Int):String {
    return Message.instance._getText(msgId);
  }

  // メッセージウィンドウを消す
  public static function hide() {
    Message.instance.visible = false;
  }

  // ウィンドウの色を変える
  public static function setWindowColor(color:Int):Void {
    Message.instance._window.color = color;
  }

  private var _window:FlxSprite;
  private var _msgList:List<FlxText>;

  // ウィンドウを下に表示しているかどうか
  private var _bDispBottom:Bool = true;
  public static function isDispBottom():Bool {
    return instance._bDispBottom;
  }

  // ウィンドウが消えるまでの時間
  private var _timer:Float;

  // メッセージCSV
  private var _csv:CsvLoader;
  // ヒントメッセージCSV
  private var _csvHint:CsvLoader;

  /**
	 * コンストラクタ
	 **/

  public function new(csv:CsvLoader, csvHint:CsvLoader) {
    super();
    // 背景枠
    _window = new FlxSprite(POS_X, POS_Y).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    _window.color = FlxColor.BLACK;
    _window.alpha = 0.5;
    this.add(_window);
    _msgList = new List<FlxText>();

    // CSVメッセージ
    _csv = csv;
    _csvHint = csvHint;

    // 非表示
    visible = false;
  }

  private var ofsY(get_ofsY, never):Float;

  private function get_ofsY() {
    var player = cast(FlxG.state, PlayState).player;
    var y = (player.ychip) * Field.GRID_SIZE;

    if(y > POS_Y - 2 * Field.GRID_SIZE) {
      // 上にする
      _bDispBottom = false;
      return POS_Y2;
    }

    if(y < POS_Y2 + 4 * Field.GRID_SIZE) {
      // 下にする
      _bDispBottom = true;
      return POS_Y;
    }

    if(_bDispBottom) {
      return POS_Y;
    }
    else {
      return POS_Y2;
    }
  }

  /**
	 * 更新
	 **/
  override public function update():Void {
    super.update();

    if(visible) {
      _timer -= FlxG.elapsed;
      if(_timer < 0) {
        // 一定時間で消える
        visible = false;
        // メッセージを消す
        while(_msgList.length > 0) {
          pop();
        }
      }
    }

    // 座標更新
    _window.y = ofsY;
    var idx = 0;
    for(text in _msgList) {
      text.y = ofsY + MSG_POS_Y + idx * DY;
      idx++;
    }
  }

  /**
	 * メッセージを末尾に追加
	 **/
  private function _push(msg:String) {
    var text = new FlxText(POS_X + MSG_POS_X, 0, WIDTH);
    text.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    text.text = msg;
    if(_msgList.length >= MESSAGE_MAX) {
      // 最大を超えたので先頭のメッセージを削除
      pop();
    }
    _msgList.add(text);

    // 座標を更新
    var idx = 0;
    for(t in _msgList) {
      t.y = ofsY + MSG_POS_Y + idx * DY;
      idx++;
    }
    this.add(text);

    // 表示する
    visible = true;
    _timer = TIMER_DISAPPEAR;
  }

  private function _push2(msgId:Int, args:Array<Dynamic>):Void {
    var msg = _csv.searchItem("id", '${msgId}', "msg");
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }
    _push(msg);
  }

  /**
   * メッセージを取得する
   * @param msgId メッセージID
   * @return メッセージ
   **/
  private function _getText(msgId:Int):String {
    return _csv.searchItem("id", '${msgId}', "msg");
  }

  /**
   * ヒントメッセージを表示する
   **/
  private function _pushHint():Void {
    // フロア番号がメッセージIDとなる
    var floor = Global.getFloor();
    var msg = _csvHint.searchItem("id", '${floor}', "msg");
    push(msg);
  }

  /**
	 * 先頭のメッセージを削除
	 **/
  public function pop() {
    var t = _msgList.pop();
    this.remove(t);
  }
}
