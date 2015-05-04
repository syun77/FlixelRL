package ;
import ItemUtil.IType;
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
	Sub;  // サブニュー操作中
}

private class _Item {
	public var id(default, default):Int;       // アイテムID
	public var type(default, default):IType;   // アイテム種別
	public var isEquip(default, default):Bool; // 装備しているかどうか
	public function new(itemid:Int) {
		id = itemid;
		type = ItemUtil.getType(id);
		isEquip = false;
	}
}

/**
 * インベントリ
 **/
class Inventory extends FlxGroup {

	private static inline var EQUIP_WEAPON:Int = 0;
	private static inline var EQUIP_ARMOR:Int = 1;
	private static inline var EQUIP_RING:Int = 2;

	// 消費アイテムメニュー
	private static inline var MENU_CONSUME = "使う";
	private static inline var MENU_EQUIP = "装備";
	private static inline var MENU_UNEQUIP = "外す";
	private static inline var MENU_THROW = "投げる";
	private static inline var MENU_PUT = "捨てる";

	// 最大
	private static inline var MAX:Int = 16;
	// ウィンドウ座標
	private static inline var POS_X = 640 + 8;
	private static inline var POS_Y = 8;
	// ウィンドウサイズ
	private static inline var WIDTH = 160 - 8*2;
	private static inline var HEIGHT = 480 - 8*2;
	// メッセージ座標オフセット
	private static inline var MSG_POS_X = 8;
	private static inline var MSG_POS_Y = 8;
	// 'E'の座標オフセット
	private static inline var EQUIP_POS_X = -8;
	private static inline var EQUIP_POS_Y = 14;
	// メッセージ表示間隔
	private static inline var DY = 26;

	// インスタンス
	public static var instance:Inventory = null;

	// 基準座標
	private var x:Float = POS_X; // X座標
	private var y:Float = POS_Y; // Y座標

	// カーソル
	private var _cursor:FlxSprite;
	private var _nCursor:Int = 0;

	// 状態
	private var _state:State = State.Main;

	// ■装備アイテム
	// 武器
	private var _weapon:Int = ItemUtil.NONE;
	public var weapon(get_weapon, null):Int;
	private function get_weapon() {
		return _weapon;
	}
	// 防具
	private var _armor:Int = ItemUtil.NONE;
	public var armor(get_armor, null):Int;
	private function get_armor() {
		return _armor;
	}
	// 指輪
	private var _ring:Int = ItemUtil.NONE;
	public var ring(get_ring, null):Int;
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

	// アイテムテキスト
	private var _txtList:List<FlxText>;
	// アイテムリスト
	private var _itemList:Array<_Item>;

	public function new() {
		super();
		// 背景枠
		var spr = new FlxSprite(POS_X, POS_Y).makeGraphic(WIDTH, HEIGHT, FlxColor.WHITE);
		spr.alpha = 0.2;
		this.add(spr);

		// カーソル
		_cursor = new FlxSprite(POS_X, POS_Y).makeGraphic(WIDTH, DY+MSG_POS_Y, FlxColor.AZURE);
		_cursor.alpha = 0.5;
		this.add(_cursor);
		// カーソルは初期状態非表示
		_cursor.visible = false;

		// テキストを登録
		_txtList = new List<FlxText>();
		for(i in 0...MAX) {
			var txt = new FlxText(x + MSG_POS_X, y + MSG_POS_Y + i*DY, 0, 160);
			txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
			_txtList.add(txt);
			this.add(txt);
		}
		_itemList = new Array<_Item>();

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
	}

	// アクティブフラグの設定
	public function setActive(b:Bool) {
		_cursor.visible = b;
	}

	private var _sub:InventoryAction = null;

	/**
	 * 更新
	 **/
	public function proc():Bool {

		switch(_state) {
			case State.Main:
				// カーソル更新
				_procCursor();

				if(FlxG.keys.justPressed.SHIFT) {
					// メニューを閉じる
					return false;
				}

				if(FlxG.keys.justPressed.SPACE) {
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
								if(_isEquipSelectedItem()) {
									// 外す
									unequip(ItemUtil.getType(itemid));
								}
								else {
									// 装備する
									equip(-1);
								}
							}
						case 1:
							// アイテムを捨てる
							delItem(-1);
					}
					// メインに戻る
					this.remove(_sub);
					_sub = null;
					_state = State.Main;
				}
				else if(FlxG.keys.justPressed.SHIFT) {
					// メインに戻る
					this.remove(_sub);
					_sub = null;
					_state = State.Main;
				}
		}


		// 更新を続ける
		return true;
	}

	private function _procCursor():Void {
		if(FlxG.keys.justPressed.UP) {
			_nCursor--;
			if(_nCursor < 0) {
				_nCursor = _itemList.length - 1;
			}
		}
		if(FlxG.keys.justPressed.DOWN) {
			_nCursor++;
			if(_nCursor >= _itemList.length) {
				_nCursor = 0;
			}
		}
		// カーソルの座標を更新
		_cursor.y = POS_Y + (_nCursor * DY);
	}

	/**
	 * アイテムの追加
	 **/
	public function addItem(itemid:Int):Void {
		_itemList.push(new _Item(itemid));
		_updateText();
	}

	/**
	 * アイテムの削除
	 * @param idx: カーソル番号 (-1指定で _nCursor を使う)
	 * @return アイテムがすべてなくなったらtrue
	 **/
	public function delItem(idx:Int):Bool {
		if(idx == -1) {
			// 現在のカーソルを使う
			idx = _nCursor;
		}

		// アイテムを削除する
		_itemList.splice(idx, 1);

		if(_nCursor >= _itemList.length) {
			// 範囲外のカーソルの位置をずらす
			_nCursor = _itemList.length - 1;
			if(_nCursor < 0) {
				_nCursor = 0;
			}
		}

		// テキストを更新
		_updateText();

		return _itemList.length == 0;
	}

	/**
	 * 選択中のアイテムを取得する
	 * @return 選択中のアイテム番号。アイテムがない場合は-1
	 **/
	public function getSelectedItem():Int {
		if(_itemList.length == 0) {
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
		if(_itemList.length == 0) {
			// アイテムを持っていない
			return false;
		}

		return _itemList[_nCursor].isEquip;
	}

	/**
	 * テキストを更新
	 **/
	private function _updateText():Void {
		var i:Int = 0;
		for(txt in _txtList) {
			if(i < _itemList.length) {
				var itemid = _itemList[i].id;
				var name = ItemUtil.getName(itemid);
				txt.text = name;
			}
			else {
				txt.text = "";
			}
			i++;
		}
	}

	/**
	 * 装備する
	 * @param idx: カーソル番号 (-1指定で _nCursor を使う)
	 **/
	public function equip(idx:Int):Void {
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
		spr.visible = true;
		spr.y = y + EQUIP_POS_Y + (idx*DY);
	}

	/**
	 * 装備を外す
	 * @param type 装備の種類
	 **/
	public function unequip(type:IType):Void {
		// 同じ種類の装備を外す
		var func = function(item:_Item) {
			if(type == item.type) {
				item.isEquip = false;
			}
		}
		forEachItemList(func);

		// 'E'を非表示にする
		var spr = _fonts[0];
		switch(type) {
			case IType.Weapon:
				spr = _fonts[EQUIP_WEAPON];
			case IType.Armor:
				spr = _fonts[EQUIP_ARMOR];
			case IType.Ring:
				spr = _fonts[EQUIP_RING];
			default:
				trace('warning: invalid type = ${type}');
		}
		spr.visible = false;
	}

	/**
	 * ItemListを連続操作する
	 **/
	private function forEachItemList(func:_Item->Void):Void {
		for(item in _itemList) {
			func(item);
		}
	}
}
