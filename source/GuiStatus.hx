package ;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * ステータス表示
 **/
class GuiStatus extends FlxGroup {
	// ステータス表示座標
	private static inline var POS_X = 640 + 8;
	private static inline var POS_Y = 4;

	// バーのサイズ
	private static inline var BAR_W = 180;
	private static inline var BAR_H = 4;

	// フロア数
	private static inline var FLOORTEXT_X = POS_X;
	private static inline var FLOORTEXT_Y = POS_Y;
	// レベルテキスト
	private static inline var LVTEXT_X = POS_X + 48;
	private static inline var LVTEXT_Y = POS_Y;
	// 所持金
	private static inline var MONEYTEXT_X = POS_X + 112;
	private static inline var MONEYTEXT_Y = POS_Y;
	// HPテキスト
	private static inline var HPTEXT_X = POS_X;
	private static inline var HPTEXT_Y = FLOORTEXT_Y + 24;
	// HPバー
	private static inline var HPBAR_X = POS_X;
	private static inline var HPBAR_Y = HPTEXT_Y + 24;
	// 満腹度
	private static inline var FULLTEXT_X = POS_X;
	private static inline var FULLTEXT_Y = HPBAR_Y + 8;

	private var _txtLv:FlxText;
	private var _txtFloor:FlxText;
	private var _txtHp:FlxText;
	private var _hpBar:FlxBar;
	private var _txtFull:FlxText;
	private var _txtMoney:FlxText;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();

		// フロアテキスト
		_txtFloor = new FlxText(FLOORTEXT_X, FLOORTEXT_Y, 128);
		_txtFloor.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		this.add(_txtFloor);

		// レベルテキスト
		_txtLv = new FlxText(LVTEXT_X, LVTEXT_Y, 128);
		_txtLv.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		this.add(_txtLv);

		// HPテキスト
		_txtHp = new FlxText(HPTEXT_X, HPTEXT_Y, 180);
		_txtHp.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		this.add(_txtHp);

		// HPバー
		_hpBar = new FlxBar(HPBAR_X, HPBAR_Y, FlxBar.FILL_LEFT_TO_RIGHT, BAR_W, BAR_H);
		_hpBar.createFilledBar(FlxColor.CRIMSON, FlxColor.CHARTREUSE);
		this.add(_hpBar);

		// 満腹度テキスト
		_txtFull = new FlxText(FULLTEXT_X, FULLTEXT_Y, 160);
		_txtFull.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		this.add(_txtFull);

		// 所持金テキスト
		_txtMoney = new FlxText(MONEYTEXT_X, MONEYTEXT_Y, 128);
		_txtMoney.alignment = "right"; // 右寄せ
		_txtMoney.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
		this.add(_txtMoney);
	}

	/**
	 * 更新
	 **/
	override public function update() {
		super.update();

		// フロア数
		_txtFloor.text = "1F";

		// レベル
		_txtLv.text = "LV:1";

		// HP
		var player = cast(FlxG.state, PlayState).player;
		var hp = player.params.hp;
		var hpmax = player.params.hpmax;
		_txtHp.text = 'HP: ${hp}/${hpmax}';
		_hpBar.percent = 100 * hp / hpmax;

		// 満腹度
		var full = player.full;
		var fullmax = player.fullmax;
		_txtFull.text = '満腹度: ${full}/${fullmax}';

		// 所持金
		var money = 123456;
		_txtMoney.text = '${money}円';
	}
}
