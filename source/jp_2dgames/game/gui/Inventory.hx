package jp_2dgames.game.gui;
import jp_2dgames.game.item.Item;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.DirUtil.Dir;
import flixel.util.FlxPoint;
import jp_2dgames.game.item.DropItem;
import jp_2dgames.game.gui.Message.Msg;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.actor.Player;
import jp_2dgames.game.item.ItemUtil.IType;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * 状態
 **/
private enum State {
  Main; // 項目選択中
  Command; // サブニュー操作中
}

/**
 * メニューモード
 **/
private enum MenuMode {
  Carry; // メインのアイテムリスト
  Feet; // 足下のアイテムリスト
}

/**
 * インベントリ
 **/
class Inventory extends FlxGroup {

  // ■戻り値
  public static inline var RET_CONTINUE:Int = 0; // 処理続行中
  public static inline var RET_CANCEL:Int   = 1; // インベントリをキャンセルして閉じた
  public static inline var RET_DECIDE:Int   = 2; // 項目を決定した
  public static inline var RET_THROW:Int    = 3; // アイテムを投げた

  // 装備アイテム
  private static inline var EQUIP_WEAPON:Int = 0;
  private static inline var EQUIP_ARMOR:Int = 1;
  private static inline var EQUIP_RING:Int = 2;
  // 装備の最大数
  private static inline var EQUIP_MAX:Int = 3;

  // 消費アイテムメニュー
  private static inline var MENU_CONSUME:Int = Msg.MENU_USE; // 使う
  private static inline var MENU_EQUIP:Int = Msg.MENU_EQUIP; // 装備
  private static inline var MENU_UNEQUIP:Int = Msg.MENU_UNEQUIP; // 外す
  private static inline var MENU_THROW:Int = Msg.MENU_THROW; // 投げる
  private static inline var MENU_PUT:Int = Msg.MENU_PUT; // 置く
  private static inline var MENU_CHANGE:Int = Msg.MENU_CHANGE; // 交換
  private static inline var MENU_PICKUP:Int = Msg.MENU_PICKUP; // 拾う

  // ページ数の最大
  private static inline var PAGE_MAX:Int = 3;
  // 1ページあたりの最大表示数
  private static inline var PAGE_DISP:Int = 8;

  // アイテム所持の最大
  private static inline var MAX:Int = (PAGE_DISP * PAGE_MAX);

  // ウィンドウ座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 8;
  // ウィンドウサイズ
  private static inline var WIDTH = 212 - 8 * 2;
  private static inline var HEIGHT = (DY * PAGE_DISP) + MSG_POS_Y + 8;//480 - 64 - 8 * 2;

  // ページ数テキストの座標
  private static inline var PAGE_X = POS_X + 8;
  private static inline var PAGE_Y = POS_Y + 4;

  // メッセージ座標オフセット
  private static inline var MSG_POS_X = 24;
  private static inline var MSG_POS_Y = 32;
  // 'E'の座標オフセット
  private static inline var EQUIP_POS_X = 4;
  private static inline var EQUIP_POS_Y = 6;
  // メッセージ表示間隔
  private static inline var DY = 26;

  // インスタンス
  public static var instance:Inventory = null;

  // 基準座標
  private var x:Float = POS_X; // X座標
  private var y:Float = POS_Y; // Y座標

  // ページ数テキスト
  private var _txtPage:FlxText;
  // ページ数
  private var _nPage:Int = 0;

  // カーソル
  private var _cursor:FlxSprite;
  private var _nCursor:Int = 0;

  // 詳細ステータス
  private var _detail:GuiStatusDetail;
  private var _bShowDetail:Bool = false;

  // 状態
  private var _state:State = State.Main;
  // メニュー表示モード
  private var _menumode:MenuMode = MenuMode.Carry;

  // プレイヤー
  private var _player:Player;

  // ■装備アイテム
  // 武器
  private var _weapon:Int = ItemUtil.NONE;
  private var weapon(get_weapon, never):Int;
  private function get_weapon() {
    return _weapon;
  }
  // 防具
  private var _armor:Int = ItemUtil.NONE;
  private var armor(get_armor, never):Int;
  private function get_armor() {
    return _armor;
  }
  // 指輪
  private var _ring:Int = ItemUtil.NONE;
  private var ring(get_ring, never):Int;
  private function get_ring() {
    return _ring;
  }

  // フォント
  private var _fonts:Array<FlxSprite>;

  // アイテムの追加
  public static function push(itemid:Int, param:ItemExtraParam) {
    instance.addItem(itemid, param);
  }
  // 装備品の取得
  public static function getWeapon():Int {
    return instance.weapon;
  }

  public static function getArmor():Int {
    return instance.armor;
  }

  public static function getRing():Int {
    return instance.ring;
  }

  public static function setItemList(items:Array<ItemData>):Void {
    instance.init(items);
  }

  public static function getItemList():Array<ItemData> {
    return instance.itemList;
  }

  // アイテム枠がいっぱいかどうか
  public static function isFull():Bool {
    return instance.getItemCountFromCarry() >= MAX;
  }
  // アイテムを所持していないかどうか
  public static function isEmpty():Bool {
    return instance.getItemCountFromCarry() <= 0;
  }

  // アイテムテキスト
  private var _txtList:List<FlxText>;
  // アイテムリスト
  private var _itemList:Array<ItemData>;
  private var itemList(get_itemList, null):Array<ItemData>;
  private function get_itemList() {
    switch(_menumode) {
      case MenuMode.Carry:
        return _itemList;
      case MenuMode.Feet:
        return _feetItem;
    }
  }
  // アイテム所持数
  public var itemcount(get, never):Int;
  private function get_itemcount() {
    return itemList.length;
  }
  // アイテム所持数をCarryから取得する
  public function getItemCountFromCarry():Int {
    return _itemList.length;
  }
  // 足下のアイテム
  private var _feetItem:Array<ItemData> = null;
  // 足下にアイテムがあるかどうか
  private function _isItemOnFeet():Bool {
    return _feetItem != null;
  }
  // NULLアイテム
  private var _itemnull = null;
  // 投げたアイテム
  private var _throwItem:ItemData = null;
  // 投げたアイテムを取得
  public function getThrowItem():ItemData {
    return _throwItem;
  }
  // 投げたアイテムの情報を消去
  public function clearThrowItem():Void {
    _throwItem = null;
  }

  // ページ内の最小番号
  private var _pageMinId(get, never):Int;
  private function get__pageMinId() {
    return _nPage * PAGE_DISP;
  }
  // ページ内の最大番号
  private var _pageMaxId(get, never):Int;
  private function get__pageMaxId() {
    var max = _pageMinId + PAGE_DISP;
    if(max > itemcount) {
      max = itemcount;
    }
    return max;
  }
  // 最大ページ数
  private var _pageMax(get, never):Int;
  private function get__pageMax() {
    return Std.int(Math.ceil(itemcount / PAGE_DISP));
  }
  // 最大ページ数 (通常アイテムリストから取得する)
  private function _getCarryPageMax():Int {
    return Std.int(Math.ceil(_itemList.length / PAGE_DISP));
  }

  // サブメニュー
  private var _cmd:InventoryCommand = null;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    // 背景枠
    var spr = new FlxSprite(POS_X, POS_Y).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
    spr.alpha = 0.2;
    this.add(spr);

    // ページ数
    _txtPage = new FlxText(PAGE_X, PAGE_Y, 0, 128);
    _txtPage.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE_S);
    this.add(_txtPage);

    // カーソル
    _cursor = new FlxSprite(POS_X, y + MSG_POS_Y).makeGraphic(WIDTH, DY, FlxColor.AZURE);
    _cursor.alpha = 0.5;
    this.add(_cursor);
    // カーソルは初期状態非表示
    _cursor.visible = false;

    // テキストを登録
    _txtList = new List<FlxText>();
    for(i in 0...PAGE_DISP) {
      var txt = new FlxText(x + MSG_POS_X, y + MSG_POS_Y + i * DY, 0, 160);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      _txtList.add(txt);
      this.add(txt);
    }

    // フォント読み込み
    _fonts = new Array<FlxSprite>();
    for(i in 0...EQUIP_MAX) {
      // var str_map = "0123456789";
      // str_map    += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      // str_map    += ".()[]#$%&'" + '"' + "!?^+-*/=;:_<>";
      // str_map    += "|@`";
      var spr = new FlxSprite(x + EQUIP_POS_X, 0).loadGraphic("assets/font/font16x16.png", true);
      spr.animation.add("1", [14], 1); // 'E'
      spr.animation.play("1");
      spr.visible = false;
      this.add(spr);
      _fonts.push(spr);
    }

    // NULLアイテム
    _itemnull = new ItemData(ItemUtil.NONE, new ItemExtraParam());
  }

  /**
   * 初期化
   **/
  private function init(items:Array<ItemData>):Void {
    // カーソルは初期状態非表示
    _cursor.visible = false;
    _nCursor = 0;

    _player = cast(FlxG.state, PlayState).player;

    // 装備を外す
    _weapon = ItemUtil.NONE;
    _armor = ItemUtil.NONE;
    _ring = ItemUtil.NONE;
    for(spr in _fonts) {
      spr.visible = false;
    }

    // アイテムを登録
    _itemList = items;
    var i = 0;
    for(item in items) {
      if(item.isEquip) {
        equip(i);
      }
      i++;
    }

    // テキスト更新
    _updateText();

    // 詳細ステータス
    _detail = new GuiStatusDetail();
    // 初期状態は非表示
    _bShowDetail = false;
  }

  /**
   * インベントリを開けるかどうか
   * @return 開ければtrue
   **/
  public function checkOpen():Bool {
    if(itemcount > 0) {
      // アイテムを所持しているので開ける
      return true;
    }
    if(DropItem.getFromPosition(_player.xchip, _player.ychip) != null) {
      // 足下にアイテムがある
      return true;
    }

    // 開けない
    return false;
  }

  /**
   * アクティブフラグの設定
   **/
  public function setActive(b:Bool) {
    // カーソル表示を切り替え
    _cursor.visible = b;

    // 足下アイテムの処理
    if(b) {
      // 所持アイテムから表示する
      _menumode = MenuMode.Carry;

      // 足下にあるアイテムを取得する
      var feet = DropItem.getFromPosition(_player.xchip, _player.ychip);
      if(feet != null) {
        // 足下にアイテムがある
        _feetItem = [feet];
      }
      else {
        // アイテムはない
        _feetItem = null;
      }

      if(isEmpty()) {
        // アイテムを所持していないので足下メニューを表示する
        _menumode = MenuMode.Feet;
        // テキスト更新
        _updateText();
      }
    }
    else {
      // 通常表示に戻しておく
      _menumode = MenuMode.Carry;
      _updateText();
    }

    // 詳細表示切り替え
    showDetail(b);
  }

  /**
   * コマンドメニューのパラメータを取得する
   **/
  private function _getMenuParam():Array<Int> {
    var item = getSelectedItem();
    var itemid = item.id;
    // 床にアイテムがあるかどうか
    var bFeet = _isItemOnFeet();
    // アイテムの所持数が最大かどうか
    var bFull = isFull();

    var p = new Array<Int>();

    if(_menumode == MenuMode.Carry) {
      // 通常モード
      if(ItemUtil.isEquip(itemid)) {
        // 装備アイテム
        if(_isEquipSelectedItem()) {
          // 装備中
          p.push(MENU_UNEQUIP);
        }
        else {
          // 装備していない
          p.push(MENU_EQUIP);
        }
      }
      else {
        // 消費アイテム
        p.push(MENU_CONSUME);
      }

      if(bFeet) {
        // 床にあるアイテムと交換
        p.push(MENU_CHANGE);
      }
      else {
        // 置く
        p.push(MENU_PUT);
      }
    }
    else {
      // 足下メニュー
      if(bFull == false) {
        // 拾える
        p.push(MENU_PICKUP);
      }
      if(ItemUtil.isConsumable(itemid)) {
        // 消費アイテムなので使える
        p.push(MENU_CONSUME);
      }
    }
    // 投げる
    p.push(MENU_THROW);

    return p;
  }

  /**
   * コマンド実行時のコールバック関数
   * @param 選んだ項目
   * @return 項目に対応する処理ID
   **/
  private function _cbAction(type:Int):Int {

    // 項目決定したらカーソルは消す
    _cursor.visible = false;

    // 現在の状態を格納
    var mode = _menumode;
    _menumode = MenuMode.Carry;

    var item = getSelectedItem();
    var itemid = item.id;
    switch(type) {
      case MENU_CONSUME:
        // 使う
        // 落ちているアイテムを使うこともあるのでモードを戻しておく
        _menumode = mode;
        useItem(-1);
        if(mode == MenuMode.Feet) {
          // 足下メニューの場合は足下アイテムを消す
          DropItem.killFromPosition(_player.xchip, _player.ychip);
        }
      case MENU_EQUIP:
        // 装備する
        equip(-1, true);
      case MENU_UNEQUIP:
        // 装備から外す
        unequip(ItemUtil.getType(itemid), true);
      case MENU_PUT:
        // 床に置く
        if(_isItemOnFeet() == false) {
          DropItem.add(_player.xchip, _player.ychip, itemid, item.param);
          delItem(-1, false);
          // メッセージ表示
          var name = ItemUtil.getName(item);
          Message.push2(Msg.ITEM_PUT, [name]);
        }
      case MENU_CHANGE:
        // 交換
        // アイテムリストから取り出す
        var item = getSelectedItem();
        delItem(-1, false, false);
        // 床のアイテムをアイテムリストに追加
        {
          var feet = _feetItem[0];
          addItem(feet.id, feet.param);
          var name = ItemUtil.getName(feet);
          // メッセージ表示
          Message.push2(Msg.ITEM_PICKUP, [name]);
          // 足下アイテムを消す
          DropItem.killFromPosition(_player.xchip, _player.ychip);
        }
        // カーソル位置の調整
        _adjustCursor();

        // 床に置く
        DropItem.add(_player.xchip, _player.ychip, itemid, item.param);
        // メッセージ表示
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_PUT, [name]);

      case MENU_PICKUP:
        // 拾う
        DropItem.pickup(_player.xchip, _player.ychip);

      case MENU_THROW:
        // 投げる
        // 落ちているアイテムを投げることもあるのでモードを戻しておく
        _menumode = mode;
        var item = getSelectedItem();
        _throwItem = new ItemData(item.id, item.param);
        // 選択しているアイテムを消す
        delItem(-1);
    }
    // 元に戻す
    _menumode = mode;

    return 1;
  }

  /**
   * 床にアイテムを置く
   **/
  private function _putItem(item:ItemData):Void {
    if(_isItemOnFeet()) {
      // 床にアイテムがあるので置けない
      return;
    }


  }

  /**
	 * 更新
	 **/
  public function proc():Int {

    switch(_state) {
      case State.Main:
        // カーソル更新
        switch(_menumode) {
          case MenuMode.Carry:
            _procCursor();
          case MenuMode.Feet:
            _procCursorFeet();
        }

        if(Key.press.B) {
          // メニューを閉じる
          return RET_CANCEL;
        }

        if(Key.press.A) {
          // コマンドメニューを開く
          var param = _getMenuParam();
          var itemid = getSelectedItem();
          _cmd = new InventoryCommand(x, y, _cbAction, param);
          this.add(_cmd);
          _state = State.Command;
        }

      case State.Command:
        // コマンドメニュー
        if(_cmd.proc() == false) {
          // 項目決定
          // メインに戻る
          this.remove(_cmd);
          _cmd = null;
          _state = State.Main;

          // 項目を決定した
          if(_throwItem != null) {
            // アイテムを投げた
            return RET_THROW;
          }
          else {
            return RET_DECIDE;
          }
        }
        else if(Key.press.B) {
          // メインに戻る
          this.remove(_cmd);
          _cmd = null;
          _state = State.Main;
        }
    }

    // 更新を続ける
    return RET_CONTINUE;
  }

  /**
   * カーソルの更新（足下メニュー）
   **/
  private function _procCursorFeet():Void {

    if(isEmpty()) {
      // 所持アイテムがない場合はページ切り替えできない
      return;
    }

    // ページを切り替えたかどうか
    var bChangePage = false;

    if(Key.press.LEFT) {
      // 通常アイテムのページ数を取得
      _nPage = _getCarryPageMax() - 1;
      bChangePage = true;
    }
    else if(Key.press.RIGHT) {
      _nPage = 0;
      bChangePage = true;
    }

    if(bChangePage) {
      _nCursor = _pageMinId;
      // 通常メニューに戻る
      _menumode = MenuMode.Carry;

      // テキスト更新
      _updateText();
      _changePage();
    }
  }

  /**
   * カーソルの更新
   **/
  private function _procCursor():Void {
    // 番号の最小値と最大値を取得する
    var min = _pageMinId;
    var max = _pageMaxId;
    var nCursor = _nCursor % PAGE_DISP;

    // 項目リストを変化するかどうか
    var bChangeItem = false;
    // 足下メニューを表示するかどうか
    var bDispFeetMenu = false;

    if(Key.press.UP) {
      // 上に移動
      _nCursor--;
      if(_nCursor < min) {
        _nCursor = max - 1;
      }
      bChangeItem = true;
    }
    else if(Key.press.DOWN) {
      // 下に移動
      _nCursor++;
      if(_nCursor >= max) {
        _nCursor = min;
      }
      bChangeItem = true;
    }
    else if(Key.press.LEFT) {
      // 前のページ
      _nPage--;
      if(_nPage < 0) {
        _nPage = _pageMax - 1;
        bDispFeetMenu = true;
      }
      _nCursor = nCursor + _nPage * PAGE_DISP;
      if(_nCursor >= itemcount) {
        _nCursor = itemcount - 1;
      }
      _updateText();
      _changePage();
      bChangeItem = true;
    }
    else if(Key.press.RIGHT) {
      // 次のページ
      _nPage++;
      if(_nPage >= _pageMax) {
        _nPage = 0;
        bDispFeetMenu = true;
      }
      _nCursor = nCursor + _nPage * PAGE_DISP;
      if(_nCursor >= itemcount) {
        _nCursor = itemcount - 1;
      }
      _updateText();
      _changePage();
      bChangeItem = true;
    }

    if(bChangeItem) {
      if(bDispFeetMenu) {
        if(_feetItem != null) {
          // 足下にアイテムがある
          _nCursor = 0;
          _nPage = 0;
          // 足下メニューに切り替え
          _menumode = MenuMode.Feet;
          // テキスト更新
          _updateText();
          _changePage();
        }
      }

      // 選択アイテムが変わったので詳細情報を更新
      _detail.setSelectedItem(getSelectedItem());

    }

    // カーソルの座標を更新
    _updateCursorPosition();
  }

  // カーソルの座標を更新
  private function _updateCursorPosition():Void {
    var idx = (_nCursor % PAGE_DISP);
    _cursor.y = POS_Y + MSG_POS_Y + (idx * DY);
  }

  // ページ切り替え
  private function _changePage():Void {
    switch(_menumode) {
      case MenuMode.Carry:
        // ページ数の更新
        if(isEmpty()) {
          // アイテムを持っていない
          _txtPage.text = Message.getText(Msg.PAGE_NOITEM);
        }
        else {
          _txtPage.text = 'Page (${_nPage+1}/${_pageMax})';
        }
      case MenuMode.Feet:
        // 足下
        _txtPage.text = Message.getText(Msg.PAGE_FEET);
    }

    // Eマークの更新
    _updateTextEquip();
  }

  /**
	 * アイテムの追加
	 **/
  public function addItem(itemid:Int, param:ItemExtraParam):Void {
    itemList.push(new ItemData(itemid, param));
    _updateText();
  }

  /**
   * カーソル位置の調整
   **/
  private function _adjustCursor():Void {
    if(_nCursor >= itemcount) {
      // 範囲外のカーソルの位置をずらす
      _nCursor = itemcount - 1;
      if(_nCursor < 0) {
        _nCursor = 0;
      }
      if(_nPage >= _pageMax) {
        _nPage = _pageMax - 1;
        if(_nPage < 0) {
          // マイナスのページにならないようにする
          _nPage = 0;
        }
      }
      // カーソルの位置を調整
      _updateCursorPosition();
    }
  }

  /**
	 * アイテムの削除
	 * @param idx カーソル番号 (-1指定で _nCursor を使う)
	 * @param bMsg 削除メッセージを表示するかどうか
	 * @param bCursorAdjust カーソル位置の調整を行うかどうか
	 * @return アイテムがすべてなくなったらtrue
	 **/
  public function delItem(idx:Int, bMsg:Bool = false, bAdjustCursor=true):Bool {
    if(idx == -1) {
      // 現在のカーソルを使う
      idx = _nCursor;
    }
    // 削除アイテムの番号を保持しておく
    var item = itemList[idx];
    var itemid = item.id;
    if(item.isEquip) {
      // 装備していたら外す
      unequip(item.type, false);
    }

    // アイテムリストから削除する
    itemList.splice(idx, 1);

    if(bAdjustCursor) {
      // カーソル位置の調整
      _adjustCursor();
    }

    // テキストを更新
    _updateText();

    if(bMsg) {
      // アイテムを捨てたメッセージ
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_DISCARD, [name]);
    }

    return itemcount == 0;
  }

  /**
	 * アイテムを使う
	 * @param idx カーソル位置。-1の場合は現在のカーソルの位置
	 **/
  public function useItem(idx:Int):Void {
    if(idx == -1) {
      idx = _nCursor;
    }

    // アイテムを使う
    var item = itemList[idx];
    ItemUtil.use(_player, item);

    // メッセージ表示
    var name = ItemUtil.getName(item);
    Message.push2(Msg.ITEM_EAT, [name]);

    // 使ったアイテムを削除
    delItem(idx);
  }

  /**
	 * 選択中のアイテムを取得する
	 * @return 選択中のアイテム情報。アイテムがない場合はNULLアイテムを返す
	 **/
  public function getSelectedItem():ItemData {
    if(itemcount == 0) {
      // アイテムを持っていない
      return _itemnull;
    }

    return itemList[_nCursor];
  }

  /**
	 * 選択中のアイテムを装備中かどうか
	 * @return 装備していればtrue
	 **/
  private function _isEquipSelectedItem():Bool {
    if(itemcount == 0) {
      // アイテムを持っていない
      return false;
    }

    return itemList[_nCursor].isEquip;
  }

  /**
	 * テキストを更新
	 **/
  private function _updateText():Void {
    var i:Int = _nPage * PAGE_DISP;
    for(txt in _txtList) {
      if(i < itemcount) {
        var item = itemList[i];
        var name = ItemUtil.getName(item);
        txt.text = name;
      }
      else {
        txt.text = "";
      }
      i++;
    }

    // ページ数の更新
    _changePage();
  }

  /**
   * 'E'の表示の更新
   **/
  private function _updateTextEquip():Void {

    // いったんすべて消す
    for(spr in _fonts) {
      spr.visible = false;
    }

    var min = _pageMinId;
    var max = _pageMaxId;
    for(i in min...max) {
      var itemdata = itemList[i];
      if(itemdata.isEquip) {
        // 装備しているのでEマークを表示
        var spr:FlxSprite = null;
        switch(itemdata.type) {
          case IType.Weapon:
            spr = _fonts[EQUIP_WEAPON];
          case IType.Armor:
            spr = _fonts[EQUIP_ARMOR];
          case IType.Ring:
            spr = _fonts[EQUIP_RING];
          default:
            throw 'Error: Invalid Equip ${itemdata.type}';
        }
        spr.visible = true;
        var idx = i % PAGE_DISP;
        spr.y = y + EQUIP_POS_Y + (idx * DY) + MSG_POS_Y;
      }
    }
  }

  /**
	 * 装備する
	 * @param idx: カーソル番号 (-1指定で _nCursor を使う)
	 **/
  public function equip(idx:Int, bMsg:Bool = false):Void {
    if(idx == -1) {
      idx = _nCursor;
    }
    var itemdata = itemList[idx];
    // 同じ種類の装備を外す
    unequip(itemdata.type);

    // 'E'文字の取得
    var spr:FlxSprite = _fonts[0];
    // 装備する
    itemdata.isEquip = true;
    switch(itemdata.type) {
      case IType.Weapon:
        _weapon = itemdata.id;
        spr = _fonts[EQUIP_WEAPON];
      case IType.Armor:
        _armor = itemdata.id;
        spr = _fonts[EQUIP_ARMOR];
      case IType.Ring:
        _ring = itemdata.id;
        spr = _fonts[EQUIP_RING];
      default:
        trace('warning: invalid itemid = ${itemdata.id}');
    }

    // 'E'の表示
    _updateTextEquip();

    if(bMsg) {
      // 装備メッセージの表示
      var name = ItemUtil.getName(itemdata);
      Message.push2(Msg.ITEM_EQUIP, [name]);
    }
  }

  /**
	 * 装備を外す
	 * @param type 装備の種類
	 **/
  public function unequip(type:IType, bMsg:Bool = false):Void {
    // 同じ種類の装備を外す
    var item:ItemData = _itemnull;
    forEachItemList(function(item2:ItemData) {
      if(type == item2.type) {
        item2.isEquip = false;
        item = item2;
      }
    });
    switch(type) {
      case IType.Weapon:
        _weapon = ItemUtil.NONE;
      case IType.Armor:
        _armor = ItemUtil.NONE;
      case IType.Ring:
        _ring = ItemUtil.NONE;
      default:
        trace('warning: invalid type = ${type}');
    }

    if(bMsg && item.id >= 0) {
      // 装備を外したメッセージの表示
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_UNEQUIP, [name]);
    }

    // 'E'の表示
    _updateTextEquip();
  }

  /**
	 * ItemListを連続操作する
	 **/
  private function forEachItemList(func:ItemData -> Void):Void {
    for(item in itemList) {
      func(item);
    }
  }

  /**
   * 詳細表示を切り替え
   **/
  public function showDetail(b:Bool):Void {
    if(b) {
      // 表示要求
      if(_bShowDetail == false) {
        // 非表示なら表示する
        this.add(_detail);
        _detail.show(getSelectedItem());
        _bShowDetail = true;
      }
    }
    else {
      // 非表示要求
      if(_bShowDetail) {
        // 表示していたら消す
        this.remove(_detail);
        _bShowDetail = false;
      }
    }
  }
}
