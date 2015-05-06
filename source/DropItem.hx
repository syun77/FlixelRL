package ;
import ItemUtil;
import flixel.group.FlxTypedGroup;
import flixel.FlxG;
import ItemUtil.IType;
import flixel.FlxSprite;

/**
 * アイテム
 **/
class DropItem extends FlxSprite {

	// 管理クラス
	public static var parent:FlxTypedGroup<DropItem> = null;
	// チップ座標
	public var xchip(default, null):Int;
	public var ychip(default, null):Int;
	// ID
	public var id(default, null):Int;
	// アイテム種別
	public var type(default, null):IType;
	// 名前
	public var name(default, null):String;

	/**
	 * コンストラクタ
	 **/
	public function new() {
		super();

		// 画像読み込み
		loadGraphic("assets/images/item.png", true);

		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// 消しておく
		kill();
	}

	/**
	 * 初期化
	 **/
	public function init(X:Int, Y:Int, type:IType, itemid:Int) {
		id = itemid;
		this.type = type;
		xchip = X;
		ychip = Y;
		x = Field.toWorldX(X);
		y = Field.toWorldY(Y);

		// 名前
		name = ItemUtil.getName(id);

		// アニメーション再生
		animation.play(ItemUtil.toString(type));
	}

	/**
	 * アニメーションを登録
	 **/
	private function _registAnim():Void {
		animation.add(ItemUtil.toString(ItemUtil.IType.Weapon), [0], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Armor), [1], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Scroll), [2], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Wand), [3], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Portion), [4], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Ring), [5], 1);
		animation.add(ItemUtil.toString(ItemUtil.IType.Food), [7], 1);
	}
}
