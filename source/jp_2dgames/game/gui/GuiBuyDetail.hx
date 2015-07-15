package jp_2dgames.game.gui;
import jp_2dgames.game.util.MyColor;
import jp_2dgames.game.util.Key;
import flixel.util.FlxAngle;
import haxe.ds.ArraySort;
import jp_2dgames.game.gui.Message.Msg;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

private enum State {
  Main;   // メイン
  Closed; // 閉じた
}

/**
 * 購入メニュー
 **/
class GuiBuyDetail extends FlxSpriteGroup {

  // アイテムの最大数
  public static inline var ITEM_MAX:Int = 8;

  // 背景の枠
  public static inline var BG_WIDTH = 344;
  public static inline var BG_HEIGHT = MSG_Y*2 + ITEM_MAX*MSG_DY;

  // テキストの幅
  private static inline var TXT_WIDTH = BG_WIDTH;

  private static inline var MSG_X = 16;
  private static inline var MSG_Y = 0;
  private static inline var MSG_DY = 24;
  // 価格
  private static inline var MSG_X2 = BG_WIDTH - 96;

  private static inline var ITEMDETAIL_X = BG_WIDTH + 16;
  private static inline var ITEMDETAIL_Y = 0;

  // インスタンス
  private static var _instance:GuiBuyDetail = null;

  // テキストリスト
  private var _txtList:Array<FlxText>;
  // 価格テキストリスト
  private var _txtPriceList:Array<FlxText>;
  // アイテムリスト
  private var _itemList:Array<ItemData>;
  public static function getItemList():Array<ItemData> {
    return _instance._itemList;
  }
  // アイテム背景
  private var _bgItemList:Array<FlxSprite>;

  // カーソル
  private var _cursor:FlxSprite;
  private var _nCursor:Int;
  private var _tCursor:Int = 0;

  // 状態
  private var _state:State = State.Main;

  private var _itemDetail:GuiItemDetail;

  /**
   * 閉じたかどうか
   **/
  public static function isClosed():Bool {
    return _instance._state == State.Closed;
  }

  public static function isEmpyt():Bool {
    return _instance._itemList.length <= 0;
  }

  /**
   * 開く
   **/
  public static function open():Void {
    FlxG.state.add(_instance);
    _instance._open();
  }

  /**
   * 開く
   **/
  private function _open():Void {
    _state = State.Main;
    // ソート
    ArraySort.sort(_itemList, function(a:ItemData, b:ItemData):Int {
      var aKey:Int = ItemUtil.getParam(a.id, "sort");
      var bKey:Int = ItemUtil.getParam(b.id, "sort");
      return aKey - bKey;
    });
    _nCursor = 0;
    _itemDetail.show(_itemList[_nCursor]);
    _updateText();
    _updateCursor();
  }

  /**
   * 生成
   **/
  public static function create(X:Float, Y:Float):Void {
    _instance = new GuiBuyDetail(X, Y);
  }

  /**
   * アイテムを追加する
   **/
  public static function addItem(item:ItemData):Void {
    _instance._addItem(item);
  }

  /**
   * アイテムを追加する
   **/
  private function _addItem(item:ItemData):Void {
    _itemList.push(item);
  }

  /**
   * アイテムリストから削除する
   **/
  private function delItem(idx:Int):Void {
    _itemList.splice(idx, 1);
    if(_nCursor >= _itemList.length) {
      _nCursor = _itemList.length-1;
      _updateCursor();
    }
    _updateText();
  }

  /**
   * アイテムリストからアイテムをすべて削除する
   **/
  public static function delItemAll():Void {
    _instance._itemList = new Array<ItemData>();
  }

  /**
   * コンストラクタ
   */
  public function new(X:Float, Y:Float) {
    super(X, Y);

    // アイテム背景
    _bgItemList = new Array<FlxSprite>();
    for(i in 0...ITEM_MAX) {
      var spr = new FlxSprite(0, (MSG_DY * i), "assets/images/ui/listitem2.png");
      spr.color = MyColor.LISTITEM_ENABLE;
      spr.alpha = 0.75;
      this.add(spr);
      _bgItemList.push(spr);
    }

    // テキスト
    _txtList = new Array<FlxText>();
    _txtPriceList = new Array<FlxText>();
    var px = MSG_X;
    var px2 = MSG_X2;
    var py = MSG_Y;
    for(i in 0...ITEM_MAX) {
      var txt = new FlxText(px, py, TXT_WIDTH);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      var txtPrice = new FlxText(px2, py, TXT_WIDTH);
      txtPrice.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      py += MSG_DY;
      this.add(txt);
      this.add(txtPrice);
      _txtList.push(txt);
      _txtPriceList.push(txtPrice);
    }

    // アイテムリスト
    _itemList = new Array<ItemData>();

    // カーソル
    _cursor = new FlxSprite(0, 0, "assets/images/ui/listitem2.png");
    _cursor.alpha = 0.3;
    _cursor.color = MyColor.CURSOR;
    this.add(_cursor);

    _nCursor = 0;

    // アイテム詳細
    _itemDetail = new GuiItemDetail(ITEMDETAIL_X, ITEMDETAIL_Y);
    this.add(_itemDetail);
  }

  /**
   * 購入実行
   **/
  private function _execBuy():Bool {
    var item = _itemList[_nCursor];
    var price = ItemUtil.getBuy(item);
    if(Global.getMoney() < price) {
      // お金が足りない
      Message.push2(Msg.SHOP_SHORT_OF_MONEY);
      return false;
    }
    if(Inventory.isFull()) {
      // アイテムが一杯なので買えない
      var name = ItemUtil.getName(item);
      Message.push2(Msg.SHOP_ITEM_FULL);
      return false;
    }

    // 購入可能
    return true;
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    switch(_state) {
      case State.Main:
        if(Key.press.UP) {
          _nCursor--;
          if(_nCursor < 0) {
            _nCursor = _itemList.length - 1;
          }
        }
        else if(Key.press.DOWN) {
          _nCursor++;
          if(_nCursor >= _itemList.length) {
            _nCursor = 0;
          }
        }

        // カーソル更新
        _updateCursor();

        if(Key.press.A) {
          // 購入実行
          if(_execBuy()) {
            // 購入可能
            var item = _itemList[_nCursor];
            var price = ItemUtil.getBuy(item);
            var name = ItemUtil.getName(item);
            // アイテムを増やす
            Inventory.push(item.id, item.param);
            // お金を減らす
            Global.useMoney(price);
            delItem(_nCursor);
            // メッセージ表示
            Message.push2(Msg.SHOP_BUY, [name, price]);

            if(_itemList.length <= 0) {
              // すべて購入したので閉じる
              _state = State.Closed;
              FlxG.state.remove(this);
            }
          }
        }
        else if(Key.press.B) {
          // キャンセル
          _state = State.Closed;
          FlxG.state.remove(this);
        }

      case State.Closed:
    }
  }

  /**
   * カーソルの更新
   **/
  private function _updateCursor():Void {
    _cursor.y = y + _nCursor * MSG_DY;
    _tCursor += 4;
    _cursor.alpha = 0.3 + 0.1 * Math.sin(_tCursor * FlxAngle.TO_RAD);
    var item = _itemList[_nCursor];
    if(item != null) {
      _itemDetail.setSelectedItem(item);
    }
  }

  /**
   * 項目テキストの更新
   **/
  private function _updateText():Void {

    // いったんすべてクリア
    for(txt in _txtList) {
      txt.text = "";
    }
    for(txt in _txtPriceList) {
      txt.text = "";
    }

    // いったん背景枠を非表示
    for(bg in _bgItemList) {
      bg.visible = false;
    }
    // テキストを設定
    var idx = 0;
    for(item in _itemList) {
      _txtList[idx].text = ItemUtil.getName(item);
      var price = ItemUtil.getBuy(item);
      _txtPriceList[idx].text = '${price}円';
      if(Global.getMoney() >= price) {
        // 購入可能
        _txtList[idx].color = MyColor.LISTITEM_TEXT;
        _txtPriceList[idx].color = MyColor.LISTITEM_TEXT;
        _bgItemList[idx].color = MyColor.LISTITEM_ENABLE;
      }
      else {
        // 買えない
        _txtList[idx].color = FlxColor.SILVER;
        _txtPriceList[idx].color = FlxColor.SILVER;
        _bgItemList[idx].color = MyColor.LISTITEM_DISABLE;
      }
      // 背景枠も更新
      _bgItemList[idx].visible = true;
      idx++;
    }
  }
}
