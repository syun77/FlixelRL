package jp_2dgames.game.state;

import jp_2dgames.game.save.GameData;
import jp_2dgames.game.util.BgWrap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
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
  private static inline var POS_Y = 80;
  private static inline var POS_DX = 184;
  private static inline var POS_DY = 32;

  // カーソル用の座標オフセット
  private static inline var CURSOR_OFS_X = -8;
  private static inline var CURSOR_OFS_Y = -4;

  // カテゴリボタン
  private static inline var CATEGORY_X = 80;
  private static inline var CATEGORY_Y = 16;
  private static inline var CATEGORY_DX = 40;

  // 詳細情報
  private static inline var INFO_X = 640;
  private static inline var INFO_Y = POS_Y;

  // 戻るボタン
  private static inline var BACK_Y = 416;

  // 収集率
  private static inline var TOTAL_RATIO_X = 432;
  private static inline var TOTAL_RATIO_Y = 24;
  private static inline var CATEGORY_RATIO_X = TOTAL_RATIO_X + 180;
  private static inline var CATEGORY_RATIO_Y = TOTAL_RATIO_Y;

  // 表示する行の最大
  private static inline var MAX_ROW:Int = 10;

  private var _txtList:Array<FlxText>;
  private var _itemList:Array<Int>;

  private var _txtInfo:FlxText;

  // 収集率
  private var _txtTotalRatio:FlxText;    // 全体
  private var _txtCategoryRatio:FlxText; // カテゴリ内

  // カーソル
  private var _cursor:FlxSprite;

  // カテゴリボタン
  private var _btnList:List<FlxButton>;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    // 背景
    this.add(new BgWrap(false));

    // CSV読み込み
    ItemUtil.csvConsumable = new CsvLoader("assets/levels/item_consumable.csv");
    ItemUtil.csvEquipment  = new CsvLoader("assets/levels/item_equipment.csv");

    // 収集率
    _txtCategoryRatio = new FlxText(CATEGORY_RATIO_X, CATEGORY_RATIO_Y, 180, "", 12);
    this.add(_txtCategoryRatio);

    _txtList = new Array<FlxText>();
    // カテゴリボタン
    _btnList = new List<FlxButton>();
    var btnX = CATEGORY_X;
    var btnY = CATEGORY_Y;
    var funcWeapon:Void->Void = null;
    for(name in ["weapon", "armor", "ring", "food", "potion", "wand", "scroll", "orb"]) {
      var btn:FlxButton = null;
      var func = function() {
        // ページ切り替え
        for(b in _btnList) {
          b.color = FlxColor.SILVER;
        }
        btn.color = FlxColor.WHITE;
        _clickCategory(name);
      }
      btn = new FlxButton(btnX, btnY, "", func);
      btn.loadGraphic('assets/images/ui/category/${name}.png', true);
      this.add(btn);
      _btnList.add(btn);

      // アニメーション
      var py = btn.y;
      btn.y = -32;
      FlxTween.tween(btn, {y:py}, 1, {ease:FlxEase.expoOut});

      if(name == "weapon") {
        funcWeapon = func;
      }

      btnX += CATEGORY_DX;
    }

    // 初期状態は武器
    funcWeapon();

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
    var BACK_X = FlxG.width/2 - 100;
    var btnBack = new MyButton(BACK_X, BACK_Y, "BACK", function() {
      FlxG.switchState(new StatsState());
    });
    this.add(btnBack);

    // 収集率
    _txtTotalRatio = new FlxText(TOTAL_RATIO_X, TOTAL_RATIO_Y, 180, "", 12);
    _txtTotalRatio.text = 'Total: ${_calcTotalRatio()}%';
    this.add(_txtTotalRatio);
  }

  private function _clickCategory(name:String):Void {
    var type = IType.Food;
    switch(name) {
      case "weapon": type = IType.Weapon;
      case "armor":  type = IType.Armor;
      case "ring":   type = IType.Ring;
      case "food":   type = IType.Food;
      case "potion": type = IType.Potion;
      case "wand":   type = IType.Wand;
      case "scroll": type = IType.Scroll;
      case "orb":    type = IType.Orb;
    }

    // 項目表示
    _dispItem(type);

    // 収集率表示
    _txtCategoryRatio.text = 'Category: ${_calcCategoryRatio(type)}%';
  }

  /**
   * 全体の収集率を計算する
   **/
  private function _calcTotalRatio():Float {
    var tbl = [
      IType.Weapon,
      IType.Armor,
      IType.Ring,
      IType.Food,
      IType.Potion,
      IType.Wand,
      IType.Scroll,
      IType.Orb
    ];
    var list = new Array<Int>();
    for(type in tbl) {
      var l = _getCategoryList(type);
      list = list.concat(l);
    }

    var cnt = 0;
    var logs = GameData.getPlayData().flgItemFind;
    for(itemID in list) {
      if(logs.indexOf(itemID) != -1) {
        cnt++;
      }
    }

    trace(cnt, list.length);

    var ret = Math.ffloor((cnt / list.length) * 10000);
    return ret / 100;
  }

  /**
   * カテゴリの収集率を取得する
   **/
  private function _calcCategoryRatio(type:IType):Float {
    var cnt = 0;
    var logs = GameData.getPlayData().flgItemFind;
    var list = _getCategoryList(type);
    for(itemID in list) {
      if(logs.indexOf(itemID) != -1) {
        cnt++;
      }
    }

    var ret = Math.ffloor((cnt / list.length) * 10000);
    return ret / 100;
  }

  private function _getCategoryList(type:IType):Array<Int> {
    var list = new Array<Int>();
    var cnt = ItemUtil.count(type);
    for(i in 0...cnt) {
      var id = ItemUtil.firstID(type) + i;
      var bLog = ItemUtil.getParam(id, "log") == 1;
      if(bLog) {
        list.push(id);
      }
    }
    return list;
  }

  /**
   * 指定のカテゴリのアイテムを表示
   **/
  private function _dispItem(type:IType):Void {

    for(txt in _txtList) {
      this.remove(txt);
    }
    _itemList = _getCategoryList(type);

    var idx = 0;
    var px = POS_X;
    var py = POS_Y;
    for(id in _itemList) {
      var txt = new FlxText(px, py, POS_DX);
      txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
      if(_isUnlock(id)) {
        txt.text = ItemUtil.getParamString(id, "name");
      }
      else {
        txt.text = "???";
      }
      this.add(txt);
      _txtList.push(txt);
      // アニメーション
      txt.alpha = 0;
      FlxTween.tween(txt, {alpha:1}, 1, {ease:FlxEase.expoOut, startDelay:idx*0.01});

      py += POS_DY;
      idx++;
      if(idx%MAX_ROW == 0) {
        py = POS_Y;
        px += POS_DX;
      }
    }
  }

  private function _isUnlock(itemID:Int):Bool {
    var logs = GameData.getPlayData().flgItemFind;
    if(logs.indexOf(itemID) == -1) {
      // 見つけていない
      return false;
    }

    // 見つけている
    return true;
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

    if(xIdx < 0 || yIdx < 0 || yIdx >= MAX_ROW) {
      // 選択していない
      return -1;
    }
    // Yに進むのでこの方法で正しい
    var idx = (MAX_ROW * xIdx) + yIdx;
    if(idx < 0 ||idx >= _itemList.length) {
      // 選択していない
      return -1;
    }

    var itemID = _itemList[idx];
    if(_isUnlock(itemID) == false) {
      // アンロックしていない
      return -2;
    }

    return itemID;
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
