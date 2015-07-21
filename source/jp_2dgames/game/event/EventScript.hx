package jp_2dgames.game.event;

import jp_2dgames.lib.CsvLoader;
import flixel.text.FlxText;
import jp_2dgames.game.util.DirUtil;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.util.FlxColor;
import jp_2dgames.lib.TmxLoader;
import flixel.FlxSprite;
import StringTools;
import flixel.FlxG;
import openfl.Assets;
import flixel.group.FlxSpriteGroup;

/**
 * 状態
 **/
private enum State {
  Exec; // スクリプト実行中
  Message; // メッセージ表示中
  End; // おしまい
}

/**
 * イベントスクリプト管理クラス
 **/
class EventScript extends FlxSpriteGroup {

  // 返却値コード
  private static inline var RET_CONTINUE:Int = 1;
  private static inline var RET_MESSAGE:Int = 2;

  // NPC番号の最大数
  private static inline var NPC_MAX:Int = 32;

  // メッセージウィンドウ
  private static inline var MSG_X:Int = 32;
  private static inline var MSG_Y:Int = 400;

  // 基準ディレクトリ
  private var _directory:String;
  private var _script:Array<String>;
  // プログラムカウンタ
  private var _pc:Int = 0;
  // 状態
  private var _state:State = State.Exec;
  // コメントブロック中かどうか
  private var _bCommentBlock:Bool = false;
  // コマンドテーブル
  private var _cmdTbl:Map<String,Array<String>->Int>;
  // 背景
  private var _back:FlxSprite;
  // NPC番号
  private var _npcList:Array<Int>;
  // メッセージテキスト
  private var _txt:FlxText;
  // メッセージCSV
  private var _csvMessage:CsvLoader;

  /**
   * コンストラクタ
   **/
  public function new(directory:String, script:String) {
    super();

    _registCommand();

    _directory = directory;
    var path = _directory + script;
    var text:String = Assets.getText(path);
    if(text == null) {
      // 読み込み失敗
      FlxG.log.warn("TmxLoader.load() tmx is null. file:'" + path + "''");
      return;
    }
    _script = text.split("\n");

    // 背景画像作成
    _back = new FlxSprite();
    this.add(_back);

    // NPC番号生成
    _npcList = new Array<Int>();
    for(i in 0...NPC_MAX) {
      _npcList.push(-1);
    }

    // メッセージテキスト生成
    _txt = new FlxText(MSG_X, MSG_Y, FlxG.width);
    _txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    this.add(_txt);

    // メッセージCSV読み込み
    _csvMessage = new CsvLoader(directory + "message.csv");
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();
  }

  public function proc():Void {
    switch(_state) {
      case State.Exec:
        while(true) {
          var bExit = _procExec();
          if(bExit) {
            break;
          }
        }

      case State.Message:
      case State.End:
    }
  }

  public function _procExec():Bool {

    if(_pc >= _script.length) {
      // おしまい
      _state = State.End;
      return true;
    }
    var line = _script[_pc];
    if(_isSkip(line)) {
      // この行はパースしない
      _pc++;
      return false;
    }
    trace(line);
    var data = line.split(",");
    _cmdTbl.get(data[0])(data.slice(1));

    _pc++;
    return false;
  }

  /**
   * 解析をスキップするかどうか
   **/
  private function _isSkip(line:String):Bool {
    if(_bCommentBlock) {
      if(line.indexOf("*/") >= 0) {
        // コメントブロック終了
        _bCommentBlock = false;
      }
      return true;
    }
    if(line.indexOf("/*") >= 0) {
      // コメントブロック開始
      _bCommentBlock = true;
      return true;
    }
    if(StringTools.trim(line) == "") {
      // 空行
      return true;
    }
    if(line.indexOf("//") >= 0) {
      // コメント
      return true;
    }

    return false;
  }

  private function _strToID(str:String):Int {
    return _npcList[Std.parseInt(str)];
  }

  private function _MAP_LOAD(args:Array<String>):Int {
    var tmx = new TmxLoader();
    var path = _directory + args[0];
    tmx.load(path, _directory);
    _createBackground(tmx);
    // コリジョンレイヤー
    var cLayer = tmx.getLayer(2);
    EventNpc.isCollision = function(i:Int, j:Int):Bool {
      return cLayer.get(i, j) > 0;
    }
    return RET_CONTINUE;
  }
  private function _NPC_CREATE(args:Array<String>):Int {
    var id = Std.parseInt(args[0]);
    var type = args[1];
    var xc = Std.parseInt(args[2]);
    var yc = Std.parseInt(args[3]);
    var dir = DirUtil.fromString(args[4]);
    _npcList[id] = EventNpc.add(type, xc, yc, dir);
    return RET_CONTINUE;
  }
  private function _NPC_COLOR(args:Array<String>):Int {
    var id = _strToID(args[0]);
    var color = Std.parseInt(args[1]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.color = color;
    });
    return RET_CONTINUE;
  }
  private function _NPC_RANDOM(args:Array<String>):Int {
    var id = _strToID(args[0]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.requestRandomWalk(true);
    });
    return RET_CONTINUE;
  }
  private function _MSG(args:Array<String>):Int {
    var id = Std.parseInt(args[0]);
    _txt.text = _csvMessage.getString(id, "msg");
    return RET_CONTINUE;
  }

  private function _registCommand():Void {
    _cmdTbl = [
      "MAP_LOAD"   => _MAP_LOAD,
      "NPC_CREATE" => _NPC_CREATE,
      "NPC_COLOR"  => _NPC_COLOR,
      "NPC_RANDOM" => _NPC_RANDOM,
      "MSG"        => _MSG,
    ];
  }


  /**
   * 背景画像の作成
   **/
  private function _createBackground(tmx:TmxLoader) {
    var w = tmx.width * tmx.tileWidth;
    var h = tmx.height * tmx.tileHeight;
    var spr = _back;
    spr.makeGraphic(w, h, FlxColor.BLACK);

    var pt = new Point();
    var rect = new Rectangle();
    for(idx in 0...tmx.getLayerCount()) {
      if(idx >= 2) {
        // idx=2はコリジョンレイヤー
        break;
      }

      // レイヤー情報を元に背景画像を作成
      var layer = tmx.getLayer(idx);
      layer.forEach(function(i, j, v) {
        if(v > 0) {
          pt.x = i * tmx.tileWidth;
          pt.y = j * tmx.tileHeight;
          var tileset = tmx.getTileset(v);
          if(tileset == null) {
            return;
          }
          rect = tileset.toRectangle(v, rect);
          var bmp = tileset.bmp;
          spr.pixels.copyPixels(bmp, rect, pt, true);
        }
      });
    }
  }
}
