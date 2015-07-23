package jp_2dgames.game.event;

import jp_2dgames.lib.Snd;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import jp_2dgames.game.util.Key;
import StringTools;
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
  Exec;    // スクリプト実行中
  Message; // メッセージ表示中
  Wait;    // 一時停止中
  End;     // おしまい
}

/**
 * イベントスクリプト管理クラス
 **/
class EventScript extends FlxSpriteGroup {

  // 返却値コード
  private static inline var RET_CONTINUE:Int = 1;
  private static inline var RET_MESSAGE:Int = 2;
  private static inline var RET_WAIT:Int = 3;

  // NPC番号の最大数
  private static inline var NPC_MAX:Int = 32;

  // メッセージウィンドウ
  private static inline var WINDOW_X:Int = 0;
  private static inline var WINDOW_Y:Int = 400-16;
  private static inline var MSG_X:Int = 128;
  private static inline var MSG_Y:Int = 400;
  private static inline var CURSOR_X:Int = 640;
  private static inline var CURSOR_Y:Int = 448;

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
  // イベント画像
  private var _sprEvent:FlxSprite;
  // メッセージテキスト
  private var _txt:FlxText;
  // メッセージCSV
  private var _csvMessage:CsvLoader;
  // メッセージウィンドウ
  private var _sprWindow:FlxSprite;
  // カーソル
  private var _sprCursor:FlxSprite;
  // UIグループ
  private var _ui:FlxSpriteGroup;
  public var ui(get, never):FlxSpriteGroup;
  private function get_ui() {
    return _ui;
  }

  // アニメーション用タイマー
  private var _tAnim:Float = 0;

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

    // UIグループ作成
    _ui = new FlxSpriteGroup();
    // イベント画像
    _sprEvent = new FlxSprite();
    _sprEvent.kill();
    _ui.add(_sprEvent);

    // メッセージウィンドウ作成
    _sprWindow = new FlxSprite(WINDOW_X, WINDOW_Y, directory + "window.png");
    _ui.add(_sprWindow);

    // メッセージテキスト生成
    _txt = new FlxText(MSG_X, MSG_Y, FlxG.width);
    _txt.setFormat(Reg.PATH_FONT, Reg.FONT_SIZE);
    _ui.add(_txt);

    // カーソル生成
    _sprCursor = new FlxSprite(CURSOR_X, CURSOR_Y, directory + "cursor.png");
    _sprCursor.visible = false;
    _ui.add(_sprCursor);

    // メッセージCSV読み込み
    _csvMessage = new CsvLoader(directory + "message.csv");
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    _tAnim += FlxG.elapsed;
    _sprCursor.y = CURSOR_Y + 1 * Math.sin(_tAnim*8);
    var currentStep = Std.int(_tAnim*8);
    var steps = 8;
    if(Std.int(_tAnim*2)%2 < 1) {
      _sprCursor.color = FlxColor.WHITE;
    }
    else {
      _sprCursor.color = FlxColor.GOLDEN;
    }
  }

  public function proc():Void {
    switch(_state) {
      case State.Exec:
        // スクリプト実行中
        while(true) {
          var bExit = _procExec();
          if(bExit) {
            break;
          }
        }

      case State.Message:
        // キー入力待ち
        if(Key.press.A) {
          // スクリプト実行に戻る
          _txt.text = "";
          _state = State.Exec;
          _sprCursor.visible = false;
          _tAnim = 0;
        }

      case State.Wait:
        // 演出中

      case State.End:
    }
  }

  /**
   * 終了チェック
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  public function _procExec():Bool {

    if(_pc >= _script.length) {
      // おしまい
      _state = State.End;
      return true;
    }

    // 行テキスト取得
    var line = _script[_pc];
    // 実行カウンタを進める
    _pc++;

    if(_isSkip(line)) {
      // この行はパースしない
      return false;
    }
//    trace(line);

    // コマンド実行
    var data = line.split(",");
    if(_cmdTbl.exists(data[0]) == false) {
      throw 'Error: Not found command. ${data[0]}';
    }
    var ret = _cmdTbl.get(data[0])(data.slice(1));
    switch(ret) {
      case RET_CONTINUE:
        // 継続する
        return false;
      case RET_MESSAGE:
        // キー入力待ち
        _state = State.Message;
        _sprCursor.visible = true;
        return true;
      case RET_WAIT:
        // 演出開始
        _state = State.Wait;
        return true;
      default:
        // 継続する
        return false;
    }

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
  private function _strToColor(str:String):Int {
    switch(str) {
      case "black": return FlxColor.BLACK;
      case "white": return FlxColor.WHITE;
      default:
        return FlxColor.BLACK;
    }
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
  private function _MAP_CLEAR(args:Array<String>):Int {
    var rect = new Rectangle(0, 0, _back.width, _back.height);
    _back.pixels.fillRect(rect, FlxColor.BLACK);

    // 描画内容を反映
    _back.dirty = true;
    _back.updateFrameData();
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
  private function _NPC_DESTROY(args:Array<String>):Int {
    var id = _strToID(args[0]);
    var type = args[1];
    var time = Std.parseFloat(args[2]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.requestKill(type, time);
    });
    return RET_CONTINUE;
  }
  private function _NPC_DESTROY_ALL(args:Array<String>):Int {
    EventNpc.parent.forEachAlive(function(npc:EventNpc) {
      npc.kill();
    });
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
  private function _NPC_WAIT(args:Array<String>):Int {
    var id = _strToID(args[0]);
    var time = Std.parseFloat(args[1]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.requestWait(time);
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
  private function _NPC_DIR(args:Array<String>):Int {
    var id  = _strToID(args[0]);
    var dir = DirUtil.fromString(args[1]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.requestDir(dir);
    });
    return RET_CONTINUE;
  }
  private function _NPC_MOVE(args:Array<String>):Int {
    var id  = _strToID(args[0]);
    var dir = DirUtil.fromString(args[1]);
    var cnt = Std.parseInt(args[2]);
    EventNpc.forEach(id, function(npc:EventNpc) {
      npc.requestMove(dir, cnt);
    });
    return RET_CONTINUE;
  }
  private function _MSG(args:Array<String>):Int {
    var id = Std.parseInt(args[0]);
    var text = _csvMessage.getString(id, "msg");
    // 改行タグを置き換え
    _txt.text = StringTools.replace(text, "<br>", "\n");
    return RET_MESSAGE;
  }
  private function _IMAGE(args:Array<String>):Int {
    var image = _directory + args[0];
    _sprEvent.revive();
    _sprEvent.alpha = 1;
    _sprEvent.loadGraphic(image);
    var cx = FlxG.width/2 - _sprEvent.width/2;
    var cy = FlxG.height/2 - _sprEvent.height/2;
    _sprEvent.x = cx;
    _sprEvent.y = FlxG.height;
    FlxTween.tween(_sprEvent, {y:cy}, 1, {ease:FlxEase.expoOut, complete:function(tween:FlxTween) {
      _state = State.Exec;
    }});

    return RET_WAIT;
  }
  private function _IMAGE_OFF(args:Array<String>):Int {
    FlxTween.tween(_sprEvent, {alpha:0}, 1, {ease:FlxEase.expoOut, complete:function(tween:FlxTween) {
      _sprEvent.kill();
      _state = State.Exec;
    }});
    return RET_WAIT;
  }
  private function _FADE_OUT(args:Array<String>):Int {
    var color = _strToColor(args[0]);
    FlxG.camera.fade(color, 1, false, function() {
      // 完了したらスクリプト実行に戻る
      _state = State.Exec;
    }, true);
    return RET_WAIT;
  }
  private function _FADE_IN(args:Array<String>):Int {
    var color = _strToColor(args[0]);
    FlxG.camera.fade(color, 1, true, function() {
      // 完了したらスクリプト実行に戻る
      _state = State.Exec;
    }, true);
    return RET_WAIT;
  }
  private function _WAIT(args:Array<String>):Int {
    var time = Std.parseFloat(args[0]);
    new FlxTimer(time, function(t:FlxTimer) {
      // 完了したらスクリプト実行に戻る
      _state = State.Exec;
    });
    return RET_WAIT;
  }
  private function _BGM(args:Array<String>):Int {
    var bgm = args[0];
    Snd.playMusic(bgm);
    return RET_CONTINUE;
  }
  private function _SE(args:Array<String>):Int {
    var se = args[0];
    Snd.playSe(se, true);
    return RET_CONTINUE;
  }

  private function _registCommand():Void {
    _cmdTbl = [
      "MAP_LOAD"        => _MAP_LOAD,
      "MAP_CLEAR"       => _MAP_CLEAR,
      "NPC_CREATE"      => _NPC_CREATE,
      "NPC_DESTROY"     => _NPC_DESTROY,
      "NPC_DESTROY_ALL" => _NPC_DESTROY_ALL,
      "NPC_COLOR"       => _NPC_COLOR,
      "NPC_WAIT"        => _NPC_WAIT,
      "NPC_RANDOM"      => _NPC_RANDOM,
      "NPC_DIR"         => _NPC_DIR,
      "NPC_MOVE"        => _NPC_MOVE,
      "MSG"             => _MSG,
      "IMAGE"           => _IMAGE,
      "IMAGE_OFF"       => _IMAGE_OFF,
      "FADE_IN"         => _FADE_IN,
      "FADE_OUT"        => _FADE_OUT,
      "WAIT"            => _WAIT,
      "BGM"             => _BGM,
      "SE"              => _SE,
    ];
  }


  /**
   * 背景画像の作成
   **/
  private function _createBackground(tmx:TmxLoader) {
    var w = tmx.width * tmx.tileWidth;
    var h = tmx.height * tmx.tileHeight;
    _back.makeGraphic(w, h, FlxColor.BLACK);

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
          _back.pixels.copyPixels(bmp, rect, pt, true);
        }
      });
    }

    // 描画内容を反映
    _back.dirty = true;
    _back.updateFrameData();
  }
}
