package jp_2dgames.game.state;

import flixel.FlxSprite;
import flixel.text.FlxText;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.item.ItemUtil;
import flixel.FlxG;
import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxState;

private class MyButton extends FlxButtonPlus {

  public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void, ?OnEnter:Void->Void, ?OnLeave:Void->Void) {
    var w = 200; // ボタンの幅
    var h = 40;  // ボタンの高さ
    var s = 20;  // フォントのサイズ
    super(X, Y, OnClick, Text, w, h);
    textNormal.size = s;
    textHighlight.size = s;

    enterCallback = OnEnter;
    leaveCallback = OnLeave;
  }
}

/**
 * アイテムログ画面
 **/
class ItemLogState extends FlxState {

  // ■定数
  private static inline var POS_X = 80;
  private static inline var POS_Y = 64;
  private static inline var POS_DX = 184;
  private static inline var POS_DY = 32;

  // カーソル用の座標オフセット
  private static inline var CURSOR_OFS_X = -8;
  private static inline var CURSOR_OFS_Y = -4;

  // 詳細情報
  private static inline var INFO_X = 640;
  private static inline var INFO_Y = POS_Y;

  // 戻るボタン
  private static inline var BACK_X = 600;
  private static inline var BACK_Y = 416;

  // 表示する行の最大
  private static inline var MAX_ROW:Int = 10;

  private var _txtList:Array<FlxText>;
  private var _itemList:Array<Int>;

  private var _txtInfo:FlxText;

  // カーソル
  private var _cursor:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // CSV読み込み
    ItemUtil.csvConsumable = new CsvLoader("assets/levels/item_consumable.csv");
    ItemUtil.csvEquipment  = new CsvLoader("assets/levels/item_equipment.csv");

    _txtList = new Array<FlxText>();
//    _dispItem(IType.Scroll);
    _dispItem(IType.Potion);

    // 詳細情報
    _txtInfo = new FlxText(INFO_X, INFO_Y, 192);
    _txtInfo.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    _txtInfo.text = "";
    this.add(_txtInfo);

    // カーソル
    _cursor = new FlxSprite();
    _cursor.loadGraphic("assets/images/ui/itemlog_cursor.png");
    this.add(_cursor);

    // 戻るボタン
    var btnBack = new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new StatsState());
    });
    this.add(btnBack);
  }

  /**
   * 指定のカテゴリのアイテムを表示
   **/
  private function _dispItem(type:IType):Void {
    _itemList = new Array<Int>();
    var cnt = ItemUtil.count(type);
    for(i in 0...cnt) {
      var id = ItemUtil.firstID(type) + i;
      var bLog = ItemUtil.getParam(id, "log") == 1;
      if(bLog) {
        _itemList.push(id);
      }
    }

    var idx = 0;
    var px = POS_X;
    var py = POS_Y;
    for(id in _itemList) {
      var txt = new FlxText(px, py, POS_DX);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      txt.text = ItemUtil.getParamString(id, "name");
      this.add(txt);
      _txtList.push(txt);
      py += POS_DY;
      idx++;
      if(idx%MAX_ROW == 0) {
        py = POS_Y;
        px += POS_DX;
      }
    }
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    ItemUtil.csvConsumable = null;
    ItemUtil.csvEquipment  = null;

    super.destroy();
  }

  /**
   * マウス座標から選択しているアイテムIDを取得する
   **/
  private function _getSelectedItemID():Int {
    var xIdx = Std.int((FlxG.mouse.x - POS_X) / POS_DX);
    var yIdx = Std.int((FlxG.mouse.y - POS_Y) / POS_DY);

    // Yに進むのでこの方法で正しい
    var idx = (MAX_ROW * xIdx) + yIdx;
    if(idx < 0 ||idx >= _itemList.length) {
      // 選択していない
      return -1;
    }

    if(false) {
      // アンロックしていない
      return -2;
    }

    return _itemList[idx];
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    // カーソル座標更新
    {
      var px = POS_X;
      var py = POS_Y;
      var xIdx = Std.int((FlxG.mouse.x - POS_X) / POS_DX);
      var yIdx = Std.int((FlxG.mouse.y - POS_Y) / POS_DY);
      px += xIdx * POS_DX;
      py += yIdx * POS_DY;
      _cursor.x = px + CURSOR_OFS_X;
      _cursor.y = py + CURSOR_OFS_Y;
    }

    // アイテム詳細更新
    {
      var itemID = _getSelectedItemID();
      if(itemID == -1) {
        // 何も選択していない
        _cursor.visible = false;
        _txtInfo.text = "";
      }
      else {
        _cursor.visible = true;
        if(itemID == -2) {
          // 見つけていないアイテム
          _txtInfo.text = "???";
        }
        else {
          _txtInfo.text = ItemUtil.getParamString(itemID, "detail");
        }
      }
    }

#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
  }
}
