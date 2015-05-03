package ;
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

/**
 * インベントリ
 **/
class Inventory extends FlxGroup {

	// 消費アイテムメニュー
	private static inline var MENU_CONSUMABLE = "使う";
	private static inline var MENU_EQUIPMENT = "装備";
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

	// アイテムの追加
	public static function push(itemid:Int) {
		instance.addItem(itemid);
	}

	// アイテムテキスト
	private var _txtList:List<FlxText>;
	// アイテムリスト
	private var _itemList:Array<Int>;

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
		_itemList = new Array<Int>();
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
					var act = MENU_CONSUMABLE;
					if(ItemUtil.isEquip(itemid)) {
						// 装備アイテム
						act = MENU_EQUIPMENT;
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
							// アイテムを使う
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
		_itemList.push(itemid);
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
			return -1;
		}

		return _itemList[_nCursor];
	}

	/**
	 * テキストを更新
	 **/
	private function _updateText():Void {
		var i:Int = 0;
		for(txt in _txtList) {
			if(i < _itemList.length) {
				var itemid = _itemList[i];
				var name = ItemUtil.getName(itemid);
				txt.text = name;
			}
			else {
				txt.text = "";
			}
			i++;
		}
	}
}
