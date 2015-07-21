package jp_2dgames.lib;

import flash.geom.Rectangle;
import flash.display.BitmapData;
import flixel.FlxG;
import openfl.Assets;

/**
 * タイルセット情報
 **/
class TmxTileset {
  // 開始チップ番号
  private var _firstGID:Int = 0;
  // 保持しているチップの数
  private var _lastGID:Int = 0;
  // 1つのタイルのサイズ
  private var _tileWidth:Int = 0;
  private var _tileHeight:Int = 0;
  // タイルの数
  private var _width:Int = 0;
  private var _height:Int = 0;
  // 画像を格納するスプライト
  private var _bmp:BitmapData;
  public var bmp(get, never):BitmapData;
  private function get_bmp() {
    return _bmp;
  }

  /**
   * コンストラクタ
   **/
  public function new(directory:String, image:String, firstGID:Int, tileWidth:Int, tileHeight:Int, imgWidth:Int, imgHeight:Int) {
    // 開始チップ番号
    _firstGID   = firstGID;
    _tileWidth  = tileWidth;
    _tileHeight = tileHeight;

    // 終端のチップ番号を求める
    _width   = Std.int(imgWidth / tileWidth);
    _height  = Std.int(imgHeight / tileHeight);
    _lastGID = _firstGID + (_width * _height) - 1;

    // チップ画像を読み込んでおく
    _bmp = FlxG.bitmap.add(directory + image).bitmap;
  }

  /**
   * 指定のチップ番号がタイルセットに含まれるかどうか
   **/
  public function hasGID(GID:Int):Bool {
    if(_firstGID <= GID && GID <= _lastGID) {
      return true;
    }
    return false;
  }

  /**
   * 指定のチップIDから描画矩形を取得する
   **/
  public function toRectangle(GID:Int, rect:Rectangle):Rectangle {
    if(hasGID(GID) == false) {
      // GIDが含まれないので何もしない
      return rect;
    }
    var gid = GID - _firstGID;
    var ox = gid % _width;
    var oy = Std.int(gid / _width);
    rect.left   = ox * _tileWidth;
    rect.top    = oy * _tileHeight;
    rect.right  = rect.left + _tileWidth;
    rect.bottom = rect.top + _tileHeight;

    return rect;
  }
}

/**
 * *.tmxファイル読み込みクラス
 **/
class TmxLoader {
  private var _layers:Array<Layer2D>;
  private var _tmpLayer:Layer2D;
  private var _properties:Map<String, String>;
  private var _tilesets:Array<TmxTileset>;
  private var _width:Int = 0;
  private var _height:Int = 0;
  private var _tileWidth:Int = 0;
  private var _tileHeight:Int = 0;
  public var width(get_width, never):Int;
  public var height(get_height, never):Int;
  public var tileWidth(get_tileWidth, never):Int;
  public var tileHeight(get_tileHeight, never):Int;

  public function new() {
    // 読み込み失敗時のテンポラリ
    _tmpLayer = new Layer2D();
  }

  /**
   * Tiled Map Editorファイルをロードする
   * @param filepath *.tmxファイルのパス
   * @param dirTileset タイルセットのフォルダ（指定するとタイルセット情報を読み込む）
   * @return Layer2D
   **/
  public function load(filepath:String, dirTileset:String=""):Void {

    _layers     = new Array<Layer2D>();
    _properties = new Map<String, String>();
    _tilesets   = new Array<TmxTileset>();

    var tmx:String = Assets.getText(filepath);
    if(tmx == null) {
      // 読み込み失敗
      FlxG.log.warn("TmxLoader.load() tmx is null. file:'" + filepath + "''");
      return;
    }

    // mapノード
    var map:Xml = Xml.parse(tmx).firstElement();
    _width = Std.parseInt(map.get("width"));
    _height = Std.parseInt(map.get("height"));
    _tileWidth = Std.parseInt(map.get("tilewidth"));
    _tileHeight = Std.parseInt(map.get("tileheight"));

    for(child in map.elements()) {
      switch(child.nodeName) {
        case "tileset":
          // tilesetノード
          if(dirTileset != "") {
            var firstgid = Std.parseInt(child.get("firstgid"));
            var name = child.get("name");
            var tilewidth = Std.parseInt(child.get("tilewidth"));
            var tileheight = Std.parseInt(child.get("tileheight"));
            for(gchild in child.elements()) {
              switch(gchild.nodeName) {
                case "image":
                  var source    = gchild.get("source");
                  var imgwidth  = Std.parseInt(gchild.get("width"));
                  var imgheight = Std.parseInt(gchild.get("height"));
                  var tileset = new TmxTileset(dirTileset, source, firstgid, tilewidth, tileheight, imgwidth, imgheight);
                  _tilesets.push(tileset);
              }
            }
          }

        case "layer":
          // layerノード
          var layer:Layer2D = new Layer2D();
          var width = Std.parseInt(child.get("width"));
          var height = Std.parseInt(child.get("height"));
          layer.initialize(width, height);
          for(gchild in child.elements()) {

            switch(gchild.nodeName) {
              case "properties":
                for(prop in gchild.elements()) {
                  var name = prop.get("name");
                  var value = prop.get("value");
                  _properties.set(name, value);
                }
              case "data":
                var data:Xml = gchild;
                // CSVノード
                var csv:Xml = data.firstChild();

                var text:String = csv.nodeValue;
                var y:Int = 0;
                for(line in text.split("\n")) {
                  if(line == "") { continue; }
                  var x:Int = 0;
                  for(str in line.split(",")) {
                    var val = Std.parseInt(str);
                    if(val > 0) {
                      layer.set(x, y, val);
                    }
                    x += 1;
                  }
                  y += 1;
                }
            }
          }
          _layers.push(layer);
      }
    }
  }

  public function getLayerCount():Int {
    return _layers.length;
  }

  public function getLayer(idx:Int):Layer2D {

    if(_layers.length == 0) {
      // 読み込めていない
      FlxG.log.warn("TmxLoader.getLayer() _layers.length is 0.");
      return _tmpLayer;
    }

    return _layers[idx];
  }

  /**
   * 指定のチップIDに対応するタイルセット取得する
   * @return 見つからなかった場合は null
   **/
  public function getTileset(GID:Int):TmxTileset {
    for(tileset in _tilesets) {
      if(tileset.hasGID(GID)) {
        // 見つかった
        return tileset;
      }
    }

    // 見つからなかった
    return null;
  }

  private function get_width() {
    return _width;
  }

  private function get_height() {
    return _height;
  }

  private function get_tileWidth() {
    return _tileWidth;
  }

  private function get_tileHeight() {
    return _tileHeight;
  }
}
