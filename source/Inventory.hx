package ;
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

		_txtList = new List<FlxText>();
		for(i in 0...MAX) {
			var txt = new FlxText(x + MSG_POS_X, y + MSG_POS_Y + i*DY, 0, 160);
			txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
			_txtList.add(txt);
			this.add(txt);
		}
		_itemList = new List<Int>();
	}

	// アイテムの追加
	public function pushItem(itemid:Int):Void {
		var idx = _itemList.length;
		var name = "アイテム";
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
