package;

import jp_2dgames.Layer2D;
import flixel.FlxSprite;
import jp_2dgames.TmxLoader;
import flixel.FlxG;
import flixel.FlxState;

/**
 * メインゲーム
 */
class PlayState extends FlxState
{
	// プレイヤー情報
	private var _player:Player;
	public var player(get_player, null):Player;
	private function get_player() {
		return _player;
	}
	// マップ情報
	private var _lField:Layer2D;
	public var lField(get_lField, null):Layer2D;
	private function get_lField() {
		return _lField;
	}
	// メッセージ
	private var _message:Message;
	public var message(get_message, null):Message;
	private function get_message() {
		return _message;
	}

	// 背景
	private var _back:FlxSprite;

	/**
	 * 生成
	 */
	override public function create():Void
	{
		super.create();

		// マップ読み込み
		var tmx = new TmxLoader();
		tmx.load("assets/levels/001.tmx");
		var layer = tmx.getLayer(0);
		// 背景レイヤーを生成
		_lField = new Layer2D();
		// 背景画像を登録
		_back = new FlxSprite();
		this.add(_back);
		// フィールドを登録
		setFieldLayer(layer);
		var pt = layer.search(Field.PLAYER);

		// プレイヤー生成
		_player = new Player(Std.int(pt.x), Std.int(pt.y));
		this.add(_player);

		// メッセージ生成
		_message = new Message();
		this.add(_message);

		// デバッグ情報設定
		FlxG.watch.add(player, "x");
		FlxG.watch.add(player, "y");
		FlxG.watch.add(player, "_xprev");
		FlxG.watch.add(player, "_yprev");
		FlxG.watch.add(player, "frameWidth");
		FlxG.watch.add(player, "width");

//		FlxG.debugger.visible = true;
		FlxG.debugger.toggleKeys = ["ALT"];
//		FlxG.debugger.drawDebug = true;
	}

	/**
	 * フィールド情報を設定する
   **/
	public function setFieldLayer(layer:Layer2D) {
		// フィールド情報をコピー
		_lField.copy(layer);

		// 背景画像を作成
		Field.createBackground(_lField, _back);
		// コリジョンレイヤーを登録
		Field.setCollisionLayer(_lField);
	}

	/**
	 * 破棄
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * 更新
	 */
	override public function update():Void
	{
		super.update();

		// デバッグ処理
		updateDebug();
	}

	private function updateDebug():Void {
	#if neko
		if(FlxG.keys.justPressed.ESCAPE) {
			// ESCキーで終了する
			throw "Terminate.";
		}
	#end

		if(FlxG.keys.justPressed.S) {
			// セーブ
			Save.save();
		}
		if(FlxG.keys.justPressed.L) {
			// ロード
			Save.load();
		}
	}
}