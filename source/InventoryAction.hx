package ;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * 状態
 **/
private enum State {
	Main; // 選択中
	End;  // おしまい
}

/**
 * インベントリのサブメニュー
 **/
class InventoryAction extends FlxGroup {

	// ウィンドウサイズ
	private static inline var WIDTH = 64;
	private static inline var DY = 26;
	private static inline var CURSOR_HEIGHT = DY;

	// 基準座標
	private var x:Float;
	private var y:Float;

	// テキスト
	private var _txtList:List<FlxText>;

	// カーソル
	private var _cursor:FlxSprite;
	private var _nCursor:Int = 0;
	public var cursor(get_cursor, null):Int;
	private function get_cursor() {
		return _nCursor;
	}

	// 状態
	private var _state:State = State.Main;

	public function new(X:Float, Y:Float, items:Array<String>) {
		super();

		x = X;
		y = Y;
		// 背景枠
		var sprBack = new FlxSprite(x, y);
		this.add(sprBack);

		// カーソル
		_cursor = new FlxSprite(x, y).makeGraphic(WIDTH, CURSOR_HEIGHT, FlxColor.AZURE);
		_cursor.alpha = 0.5;
		this.add(_cursor);

		var i:Int = 0;
		_txtList = new List<FlxText>();
		for(item in items) {
			var px = x;
			var py = y + (i * DY);
			var txt = new FlxText(px, py, 0, WIDTH);
			txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
			txt.text = item;
			_txtList.add(txt);
			this.add(txt);
			i++;
		}

		// 背景枠作成
		sprBack.makeGraphic(WIDTH, i * DY, FlxColor.BLACK);
//		sprBack.alpha = 0.5;

	}

	/**
	 * 更新
	 * @return 項目決定したらfalseを返す
	 **/
	public function proc():Bool {

		switch(_state) {
			case State.Main:
				// カーソル更新
				_procCursor();
				if(Key.press.A) {
					_state = State.End;
				}

			case State.End:
				// 何もしない
				return false;
		}

		return true;
	}

	/**
	 * カーソル更新
	 **/
	private function _procCursor():Void {
		if(Key.press.UP) {
			_nCursor--;
			if(_nCursor < 0) {
				_nCursor = _txtList.length - 1;
			}
		}
		if(Key.press.DOWN) {
			_nCursor++;
			if(_nCursor >= _txtList.length) {
				_nCursor = 0;
			}
		}
		// カーソルの座標を更新
		_cursor.y = y + (_nCursor * DY);
	}
}
