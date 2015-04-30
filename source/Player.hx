package ;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import DirUtil;

/**
 * プレイヤー
 */
class Player extends Actor {

	private var _target:Enemy = null;

	/**
	 * 生成
	 */
	public function new(X:Int, Y:Int) {
		super();

		var params = new Params();

		// 初期化
		init(X, Y, Dir.Down, params);
		// プレイヤーはID「0」にしておく
		_id = 0;
		// 名前を設定
		_name = "プレイヤー";

		// アニメーションを登録
		_registAnim();

		// 中心を基準に描画
		offset.set(width/2, height/2);

		// キー入力待ち状態にする
		_change(Actor.State.KeyInput);
		_stateprev = _state;
	}

	// アニメーション名を取得する
	private function getAnimName(bStop:Bool, dir:Dir):String {
		var pre = bStop ? "stop" : "walk";
		var suf = DirUtil.toString(dir);

		return pre + "-" + suf;
	}

	// アニメーションを再生
	private function changeAnim():Void {
		var name = getAnimName(_bStop, _dir);
		animation.play(name);
	}

	// 更新
	override public function proc():Void {
		switch(_state) {
		case Actor.State.KeyInput:
			_updateKeyInput();

		case Actor.State.Inventory:
			// 何もしない

		case Actor.State.Standby:
			// 何もしない

		case Actor.State.ActBegin:
			// 何もしない

		case Actor.State.Act:
			var val = Calc.damage(this, _target, 0, 0);
			if(_target.damage(val)) {
				// 敵を倒した
				Message.push('${_target.name}を倒した');
				_target.kill();
				Particle.start(Particle.PType.Ring, _target.x, _target.y, FlxColor.YELLOW);
			}
			_change(Actor.State.TurnEnd);

		case Actor.State.ActEnd:
			// 何もしない

		case Actor.State.MoveBegin:
			// 何もしない

		case Actor.State.Move:
			if(_updateWalk()) {
				_change(Actor.State.TurnEnd);
			}

		case Actor.State.MoveEnd:
			// 何もしない

		case Actor.State.TurnEnd:
			// 何もしない
		}

		changeAnim();
	}

	/**
	 * 更新・キー入力待ち
	 **/
	private function _updateKeyInput():Void {
		_bStop = true;

		if(FlxG.keys.justPressed.SPACE) {
			// アイテムを拾えるかどうかをチェック
			var bFind = false;
			var func = function(item:DropItem) {
				if(checkPosition(item.xchip, item.ychip)) {
					// 拾える
					Message.push('${item.name}を拾った');
					bFind = true;
					Inventory.push(item.id);
					item.kill();
				}
			}
			DropItem.parent.forEachAlive(func);
			if(bFind) {
				// アイテムを拾った
				return;
			}
		}

		if(FlxG.keys.justPressed.SHIFT) {
			// メニューを開く
			_change(Actor.State.Inventory);
			return;
		}

		var xnext = Std.int(_xnext);
		var ynext = Std.int(_ynext);
		if(FlxG.keys.pressed.LEFT) {
			// 左へ進む
			_dir = Dir.Left;
			xnext -= 1;
		}
		else if(FlxG.keys.pressed.UP) {
			// 上へ進む
			_dir = Dir.Up;
			ynext -= 1;
		}
		else if(FlxG.keys.pressed.RIGHT) {
			// 右へ進む
			_dir = Dir.Right;
			xnext += 1;
		}
		else if(FlxG.keys.pressed.DOWN) {
			// 下へ進む
			_dir = Dir.Down;
			ynext += 1;
		}
		else {
			// 移動しない
			return;
		}

		// 移動先に敵がいるかどうかチェック
		_target = null;
		var func = function(e:Enemy) {
			if(e.checkPosition(xnext, ynext)) {
				// 敵がいた
				_target = e;
			}
		}
		Enemy.parent.forEachAlive(func);

		if(_target != null) {
			// 敵がいるので攻撃する
			_xtarget = xnext;
			_ytarget = ynext;
			_change(Actor.State.ActBegin);
			return;
		}

		// 移動先チェック
		if(Field.isCollision(xnext, ynext) == false) {
			// 移動可能
			_xnext = xnext;
			_ynext = ynext;
			_bStop = false;
			_change(Actor.State.MoveBegin);
			_tMove = 0;
		}
	}

	/**
	 * アニメーションの登録
	 **/
	private function _registAnim():Void {
		// アニメーションとして読み込む
		loadGraphic("assets/images/player.png", true);

		// アニメーションを登録
		// 待機アニメ
		// アニメーション速度
		var speed = 2;
		animation.add(getAnimName(true, Dir.Left), [0, 1], speed);
		animation.add(getAnimName(true, Dir.Up), [4, 5], speed);
		animation.add(getAnimName(true, Dir.Right), [8, 9], speed);
		animation.add(getAnimName(true, Dir.Down), [12, 13], speed);

		// 歩きアニメ
		speed = 6;
		animation.add(getAnimName(false, Dir.Left), [2, 3], speed);
		animation.add(getAnimName(false, Dir.Up), [6, 7], speed);
		animation.add(getAnimName(false, Dir.Right), [10, 11], speed);
		animation.add(getAnimName(false, Dir.Down), [14, 15], speed);
	}
}
