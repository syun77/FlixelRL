package ;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

/**
 * インベントリ
 **/
class Inventory extends FlxGroup {

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

	// アイテムの追加
	public static function push(itemid:Int) {
		instance.pushItem(itemid);
	}

	// アイテムテキスト
	private var _txtList:List<FlxText>;
	// アイテムリスト
	private var _itemList:List<Int>;

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
		_itemList = new List<Int>();
	}

	// アクティブフラグの設定
	public function setActive(b:Bool) {
		_cursor.visible = b;
	}

	/**
	 * 更新
	 **/
	public function proc():Bool {
		// カーソル更新
		_procCursor();

		if(FlxG.keys.justPressed.SHIFT) {
			// メニューを閉じる
			return false;
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
	public function pushItem(itemid:Int):Void {
		var idx = _itemList.length;
		var name = ItemUtil.getName(itemid);
		var i = 0;
		for(txt in _txtList) {
			if(i == idx) {
				txt.text = name;
			}
			i++;
		}
		_itemList.push(itemid);

	}
}
