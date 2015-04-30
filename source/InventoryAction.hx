package ;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * インベントリのサブメニュー
 **/
class InventoryAction extends FlxGroup {

	// ウィンドウサイズ
	private static inline var WIDTH = 64;
	private static inline var DY = 26;

	// 基準座標
	private var x:Float;
	private var y:Float;

	// テキスト
	private var txtList:List<FlxText>;

	public function new(X:Float, Y:Float, items:Array<String>) {
		super();

		x = X;
		y = Y;
		// 背景枠
		var sprBack = new FlxSprite(x, y);
		this.add(sprBack);

		var i:Int = 0;
		txtList = new List<FlxText>();
		for(item in items) {
			var px = x;
			var py = y + (i * DY);
			var txt = new FlxText(px, py, 0, WIDTH);
			txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
			txt.text = item;
			txtList.add(txt);
			this.add(txt);
			i++;
		}

		// 背景枠作成
		sprBack.makeGraphic(WIDTH, i * DY, FlxColor.BLACK);
		sprBack.alpha = 0.5;
	}
}
