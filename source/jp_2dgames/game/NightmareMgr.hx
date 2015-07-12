package jp_2dgames.game;

import jp_2dgames.lib.Snd;
import jp_2dgames.game.NightmareMgr.NightmareSkill;
import jp_2dgames.game.NightmareMgr.NightmareSkill;
import jp_2dgames.game.NightmareMgr.NightmareSkill;
import jp_2dgames.lib.CsvLoader;
import jp_2dgames.game.actor.Enemy;
import jp_2dgames.game.state.PlayState;
import flixel.FlxG;
import flixel.util.FlxPoint;
import jp_2dgames.lib.Layer2D;

/**
 * ナイトメア特殊スキル
 **/
enum NightmareSkill {
  None;        // なし
  AutoRecover; // 自動回復無効
  Hungry;      // 満腹度減少率上昇
  WeaponBreak; // 強制武器破壊
  Wand;        // 杖使用不可
  Ring;        // 指輪無効化
  Attack;      // 通常攻撃不可
  Potion;      // 薬使用不可
  Scroll;      // 巻物使用不可
  Unknown;     // 敵をすべてアンノウンにする
}

/**
 * ナイトメア管理
 **/
class NightmareMgr {
  public static var instance:NightmareMgr = null;

  /**
   * ナイトメア出現ターン数を取得する
   **/
  public static function getTurnLimit():Int {
    return instance._getTurnLimit();
  }
  private function _getTurnLimit():Int {
    return _csv.getInt(_lv, "turn");
  }

  /**
   * ナイトメア敵IDを取得する
   **/
  public static function getEnemyID():Int {
    return instance._getEnemyID();
  }
  private function _getEnemyID():Int {
    return _csv.getInt(_lv, "enemy_id");
  }

  /**
   * ナイトメア特殊スキルを取得する
   **/
  public static function getSkill():NightmareSkill {
    // TODO: テスト用にスキルを有効化
//    return NightmareSkill.Unknown;

    if(Exists() == false) {
      // 存在していないのでスキル無効
      return NightmareSkill.None;
    }

    return instance._getSkillRaw();
  }
  public static function getSkillRaw():NightmareSkill {
    return instance._getSkillRaw();
  }
  private function _getSkillRaw():NightmareSkill {
    switch(_csv.getString(_lv, "skill")) {
      case "auto_recover": return NightmareSkill.AutoRecover;
      case "hungry":       return NightmareSkill.Hungry;
      case "weapon_break": return NightmareSkill.WeaponBreak;
      case "wand":         return NightmareSkill.Wand;
      case "ring":         return NightmareSkill.Ring;
      case "attack":       return NightmareSkill.Attack;
      case "potion":       return NightmareSkill.Potion;
      case "scroll":       return NightmareSkill.Scroll;
      case "unknown":      return NightmareSkill.Unknown;
      default:             return NightmareSkill.None;
    }
  }

  /**
   * ナイトメア特殊スキル名を取得する
   **/
  public static function getSkillName():String {
    return instance._getSkillName();
  }
  private function _getSkillName():String {
    switch(_getSkillRaw()) {
      case NightmareSkill.None: return "なし";
      case NightmareSkill.AutoRecover: return "自動回復無効";
      case NightmareSkill.Hungry: return "満腹度減少率上昇";
      case NightmareSkill.WeaponBreak: return "強制武器破壊";
      case NightmareSkill.Wand: return "杖使用不可";
      case NightmareSkill.Ring: return "指輪無効化";
      case NightmareSkill.Attack: return "通常攻撃不可";
      case NightmareSkill.Potion: return "薬使用不可";
      case NightmareSkill.Scroll: return "巻物使用不可";
      case NightmareSkill.Unknown: return "敵の見た目変化";
    }
  }

  // ナイトメアが存在しているかどうか
  private var _exists:Bool;
  public static function Exists():Bool {
    return instance._exists;
  }
  // ナイトメア出現テーブル
  private var _csv:CsvLoader;
  // ナイトメア出現ターン数
  private var _turn(get, set):Int;
  private function get__turn() {
    return Global.getTurnLimitNightmare();
  }
  private function set__turn(v:Int):Int {
    Global.setTurnLimitNightmare(v);
    return v;
  }
  // ナイトメアレベル
  private var _lv(get, set):Int;
  private function get__lv() {
    return Global.getNightmareLv();
  }
  private function set__lv(v:Int):Int {
    Global.setNightmareLv(v);
    return v;
  }

  /**
   * コンストラクタ
   **/
  public function new(csv:CsvLoader) {
    _exists = false;
    _csv    = csv;
  }

  /**
   * 次のターンに進む
   **/
  public static function nextTurn(layer:Layer2D):Void {
    instance._nextTurn(layer);
  }
  private function _nextTurn(layer:Layer2D):Void {
    // ターン数を減らす
    _turn -= 1;
    if(_turn <= 0) {
      _turn = 0;
      if(_exists == false) {
        if(_existsNightmare()) {
          // すでに存在している
          _exists = true;
        }
        else {
          var pt = _searchNightmarePosition(layer);
          if(pt != null) {
            // ナイトメア出現
            var px = Std.int(pt.x);
            var py = Std.int(pt.y);
            pt.put();
            var e = Enemy.add(_getEnemyID(), px, py);
            if(e != null) {
              // 画面を揺らす
              FlxG.camera.shake(0.01);
              _exists = true;
              Snd.playMusic("nightmare");
            }

            if(getSkill() == NightmareSkill.Unknown) {
              // すべての敵をアンノウン化
              var eid = getEnemyID();
              Enemy.parent.forEachAlive(function(e:Enemy) {
                if(e.id != eid) {
                  e.changeUnknown();
                }
              });
            }
          }
        }
      }
    }

    if(_exists) {
      // 倒したかどうかをチェック
      if(_existsNightmare() == false) {
        // ナイトメアを倒した
        if(_csv.hasId(_lv+1)) {
          // レベルアップ
          _lv++;
        }

        // 出現ターン数を設定
        _turn = _getTurnLimit();

        // BGMを元に戻す
        Snd.playMusicPrev();

        _exists = false;
      }
    }
  }

  /**
   * 次のフロアに進むときの処理
   **/
  public static function nextFloor() {
    instance._nextFloor();
  }
  private function _nextFloor():Void {
    // 残りターン数を回復
    var add = _csv.getInt(_lv, "add");
    if(_turn < add) {
      // 回復値より小さければ足し込む
      _turn += add;
      if(_turn > add) {
        _turn = add;
      }
    }
  }

  /**
   * ナイトメアが存在するかどうか
   **/
  private function _existsNightmare():Bool {
    var ret = false;

    Enemy.parent.forEachAlive(function(e:Enemy) {
      if(e.id == _getEnemyID()) {
        ret = true;
      }
    });

    return ret;
  }

  /**
   * ナイトメアを出現させる
   **/
  private function _searchNightmarePosition(layer:Layer2D):FlxPoint {

    var player = cast(FlxG.state, PlayState).player;

    // まずはプレイヤーが登場した位置に出現できるかどうかを調べる
    {
      var pt = layer.search(Field.PLAYER);
      var px = Std.int(pt.x);
      var py = Std.int(pt.y);
      if(player.existsPosition(px, py) == false) {
        if(Enemy.getFromPosition(px, py) == null) {
          // 生成可能
          return pt;
        }
      }
    }

    // チャレンジ回数
    var cnt = 10;
    for(i in 0...cnt) {
      var pt = layer.searchRandom(Field.ENEMY);
      if(pt == null) {
        break;
      }
      var px = Std.int(pt.x);
      var py = Std.int(pt.y);

      if(player.existsPosition(px, py)) {
        // 生成できないのでやり直す
        continue;
      }
      if(Enemy.getFromPosition(px, py) != null) {
        // 生成できないのでやり直す
        continue;
      }

      // 生成可能
      return pt;
    }

    // 出現できない
    return null;
  }
}
