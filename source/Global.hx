package ;

import DirUtil.Dir;
import jp_2dgames.TextUtil;

/**
 * グローバルデータ
 **/
class Global {
	// フロア数
	private static var _floor:Int = 1;

	/**
	 * フロア数の取得
	 **/
	public static function getFloor():Int {
		return _floor;
	}

	/**
	 * 現在のフロアのマップデータのパスを取得する
	 **/
	public static function getFloorMap():String {
		var map = TextUtil.fillZero(_floor, 3);
		return 'assets/levels/${map}.tmx';
	}

	/**
	 * 次のフロアに進む
	 **/
	public static function nextFloor():Void {
		_floor++;
		// TODO: 最後まで進んだら最初に戻る
		if(_floor > 3) {
			_floor = 1;
		}
	}

	// アイテムデータ
	private static var _items:Array<ItemData> = new Array<ItemData>();

	/**
	 * アイテムデータを設定する
	 **/
	public static function setItemList(items:Array<ItemData>=null):Void {
		if(items == null) {
			// グローバルデータにあるアイテムデータを使う
			items = _items;
		}
		else {
			// 外部のデータを使う
			_items = items;
		}
		Inventory.setItemList(items);
	}

	// プレイヤーステータス
	private static var _params:Params = new Params();
	public static function initPlayer(player:Player, x:Int, y:Int, dir:Dir, params:Params=null):Void {
		if(params == null) {
			// グローバルデータにあるパラメータを使う
			params = _params;
		}
		else {
			// 外部のデータを使う
			_params = params;
		}

		player.init(x, y, dir, params);
	}
}
