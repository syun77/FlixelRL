package jp_2dgames.game.gui;
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
  Main; // 選択中
  Sub;
  // サブニュー操作中
}

/**
 * インベントリ
 **/
class Inventory extends FlxGroup {

  // ■戻り値
  public static inline var RET_CONTINUE:Int = 0; // 処理続行中
  public static inline var RET_CANCEL:Int   = 1; // インベントリをキャンセルして閉じた
  public static inline var RET_DECIDE:Int   = 2; // 項目を決定した

  private static inline var EQUIP_WEAPON:Int = 0;
  private static inline var EQUIP_ARMOR:Int = 1;
  private static inline var EQUIP_RING:Int = 2;

  // 消費アイテムメニュー
  private static inline var MENU_CONSUME = "使う";
  private static inline var MENU_EQUIP = "装備";
  private static inline var MENU_UNEQUIP = "外す";
  private static inline var MENU_THROW = "投げる";
  private static inline var MENU_PUT = "捨てる";

  // ページ数の最大
  private static inline var PAGE_MAX:Int = 3;
  // 1ページあたりの最大表示数
  private static inline var PAGE_DISP:Int = 8;

  // アイテム所持の最大
  private static inline var MAX:Int = (PAGE_DISP * PAGE_MAX);

  // ウィンドウ座標
  private static inline var POS_X = 640 + 8;
  private static inline var POS_Y = 106;
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
  public static function push(itemid:Int) {
    instance.addItem(itemid);
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
    return instance.itemcount >= MAX;
  }

  // アイテムテキスト
  private var _txtList:List<FlxText>;
  // アイテムリスト
  private var _itemList:Array<ItemData>;
  private var itemList(get_itemList, null):Array<ItemData>;
  private function get_itemList() {
    return _itemList;
  }
  // アイテム所持数
  public var itemcount(get, never):Int;
  private function get_itemcount() {
    return _itemList.length;
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

  // サブメニュー
  private var _sub:InventoryAction = null;

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
    for(i in 0...3) {
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

    FlxG.watch.add(this, "_nCursor");
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
   * アクティブフラグの設定
   **/
  public function setActive(b:Bool) {
    // カーソル表示を切り替え
    _cursor.visible = b;

    // 詳細表示切り替え
    showDetail(b);
  }

  /**
	 * 更新
	 **/
  public function proc():Int {

    switch(_state) {
      case State.Main:
        // カーソル更新
        _procCursor();

        if(Key.press.B) {
          // メニューを閉じる
          return RET_CANCEL;
        }

        if(Key.press.A) {
          // サブメニューを開く
          var itemid = getSelectedItem();
          var act = MENU_CONSUME;
          if(ItemUtil.isEquip(itemid)) {
            // 装備アイテム
            act = MENU_EQUIP;
            if(_isEquipSelectedItem()) {
              // 装備中なので外す
              act = MENU_UNEQUIP;
            }
          }
          _sub = new InventoryAction(x, y, [act, MENU_PUT]);
          this.add(_sub);
          _state = State.Sub;
        }

      case State.Sub:
        if(_sub.proc() == false) {
          // 項目決定
          switch(_sub.cursor) {
            case 0:
              // アイテムを使う・装備する・外す
              var itemid = getSelectedItem();
              if(ItemUtil.isEquip(itemid)) {
                // 装備する
                if(_isEquipSelectedItem()) {
                  // 外す
                  unequip(ItemUtil.getType(itemid), true);
                }
                else {
                  // 装備する
                  equip(-1, true);
                }
              }
              else {
                // アイテムを使う
                useItem(-1);
              }
            case 1:
              // アイテムを捨てる
              delItem(-1, true);
          }
          // メインに戻る
          this.remove(_sub);
          _sub = null;
          _state = State.Main;

          // 項目を決定した
          return RET_DECIDE;
        }
        else if(Key.press.B) {
          // メインに戻る
          this.remove(_sub);
          _sub = null;
          _state = State.Main;
        }
    }

    // 更新を続ける
    return RET_CONTINUE;
  }

  private function _procCursor():Void {
    // 番号の最小値と最大値を取得する
    var min = _pageMinId;
    var max = _pageMaxId;
    var nCursor = _nCursor % PAGE_DISP;
    var bChangeItem = false;

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
      }
      _nCursor = nCursor + _nPage * PAGE_DISP;
      if(_nCursor >= itemcount) {
        _nCursor = itemcount - 1;
      }
      _updateText();
      _changePage();
      bChangeItem = true;
    }

    // カーソルの座標を更新
    {
      var idx = (_nCursor % PAGE_DISP);
      _cursor.y = POS_Y + MSG_POS_Y + (idx * DY);
    }

    if(bChangeItem) {
      // 選択アイテムが変わった
      _changeSelectItem();
    }
  }

  /**
   * 選択しているアイテムが替わった
   **/
  private function _changeSelectItem():Void {
    // 差分テキスト非表示
    _detail.clearAtkDiff();
    _detail.clearDefDiff();
    var itemid = getSelectedItem();
    var type = ItemUtil.getType(itemid);
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
        var now = ItemUtil.getParam(weapon, "atk");
        var next = ItemUtil.getParam(itemid, "atk");
        _detail.setAtkDiff(next - now);
      case IType.Armor:
        var now = ItemUtil.getParam(armor, "def");
        var next = ItemUtil.getParam(itemid, "def");
        _detail.setDefDiff(next - now);
      case IType.Ring:
      case IType.Food:
      case IType.Money:
      case IType.None:
      case IType.Portion:
      case IType.Scroll:
      case IType.Wand:
    }
  }

  // ページ切り替え
  private function _changePage():Void {
    // ページ数の更新
    _txtPage.text = 'Page (${_nPage+1}/${_pageMax})';

    // Eマークの更新
    _updateTextEquip();
  }

  /**
	 * アイテムの追加
	 **/
  public function addItem(itemid:Int):Void {
    _itemList.push(new ItemData(itemid));
    _updateText();
  }

  /**
	 * アイテムの削除
	 * @param idx: カーソル番号 (-1指定で _nCursor を使う)
	 * @return アイテムがすべてなくなったらtrue
	 **/
  public function delItem(idx:Int, bMsg:Bool = false):Bool {
    if(idx == -1) {
      // 現在のカーソルを使う
      idx = _nCursor;
    }
    // 削除アイテムの番号を保持しておく
    var itemid = _itemList[idx].id;

    // アイテムを削除する
    _itemList.splice(idx, 1);

    if(_nCursor >= itemcount) {
      // 範囲外のカーソルの位置をずらす
      _nCursor = itemcount - 1;
      if(_nCursor < 0) {
        _nCursor = 0;
      }
    }

    // テキストを更新
    _updateText();

    if(bMsg) {
      // アイテムを捨てたメッセージ
      var name = ItemUtil.getName(itemid);
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
    var item = _itemList[idx];

    switch(item.type) {
      case IType.Portion:
        // 薬
        var val = ItemUtil.getParam(item.id, "hp");
        if(val > 0) {
          _player.addHp(val);
        }
        else {
          val = ItemUtil.getParam(item.id, "hp2");
          _player.addHp2(val);
        }
      case IType.Food:
        // 食糧
        var val = ItemUtil.getParam(item.id, "food");
        _player.addFood(val);
      default:
        // ここにくることはない
        trace('Error: Invalid item ${item.id}');
    }

    var name = ItemUtil.getName(item.id);
    Message.push2(Msg.ITEM_EAT, [name]);
    delItem(idx);
  }

  /**
	 * 選択中のアイテムを取得する
	 * @return 選択中のアイテム番号。アイテムがない場合は-1
	 **/
  public function getSelectedItem():Int {
    if(itemcount == 0) {
      // アイテムを持っていない
      return ItemUtil.NONE;
    }

    return _itemList[_nCursor].id;
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

    return _itemList[_nCursor].isEquip;
  }

  /**
	 * テキストを更新
	 **/
  private function _updateText():Void {
    var i:Int = _nPage * PAGE_DISP;
    for(txt in _txtList) {
      if(i < itemcount) {
        var itemid = _itemList[i].id;
        var name = ItemUtil.getName(itemid);
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
      var itemdata = _itemList[i];
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
    var itemdata = _itemList[idx];
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
      var name = ItemUtil.getName(itemdata.id);
      Message.push2(Msg.ITEM_EQUIP, [name]);
    }
  }

  /**
	 * 装備を外す
	 * @param type 装備の種類
	 **/
  public function unequip(type:IType, bMsg:Bool = false):Void {
    // 同じ種類の装備を外す
    var itemid:Int = -1;
    var func = function(item:ItemData) {
      if(type == item.type) {
        item.isEquip = false;
        itemid = item.id;
      }
    }
    forEachItemList(func);

    if(bMsg && itemid >= 0) {
      // 装備を外したメッセージの表示
      var name = ItemUtil.getName(itemid);
      Message.push2(Msg.ITEM_UNEQUIP, [name]);
    }

    // 'E'の表示
    _updateTextEquip();
  }

  /**
	 * ItemListを連続操作する
	 **/
  private function forEachItemList(func:ItemData -> Void):Void {
    for(item in _itemList) {
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

    _changeSelectItem();
  }
}
