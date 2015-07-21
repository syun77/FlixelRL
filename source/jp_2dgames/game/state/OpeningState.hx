package jp_2dgames.game.state;
import flash.geom.Rectangle;
import flash.geom.Point;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import jp_2dgames.lib.TmxLoader;
import jp_2dgames.lib.Layer2D;
import jp_2dgames.game.util.DirUtil;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import jp_2dgames.game.event.EventNpc;
import flixel.FlxState;

/**
 * オープニング画面
 **/
class OpeningState extends FlxState {

  var playerID:Int = 0;
  var catID:Int = 0;
  var _back:FlxSprite;

  /**
   * 生成
   **/
  override public function create():Void {
    super.create();

    var tmx = new TmxLoader();
    tmx.load("assets/events/001.tmx", "assets/events/");
    _createBackground(tmx);
    // コリジョンレイヤー
    var cLayer = tmx.getLayer(2);
    EventNpc.isCollision = function(i:Int, j:Int):Bool {
      return cLayer.get(i, j) > 0;
    }

    EventNpc.parent = new FlxTypedGroup<EventNpc>(32);
    for(i in 0...EventNpc.parent.maxSize) {
      var npc = new EventNpc();
      npc.ID = i;
      this.add(npc);
      EventNpc.parent.add(npc);
    }

    playerID = EventNpc.add("player", 12, 5, Dir.Down);

    for(i in 0...4) {
      catID = EventNpc.add("cat", 6+i, 4+i, DirUtil.random());
      EventNpc.forEach(catID, function(npc:EventNpc) {
        npc.requestRandomWalk(true);
      });
    }
  }

  /**
   * 背景画像の作成
   **/
  private function _createBackground(tmx:TmxLoader) {
    var w = tmx.width * tmx.tileWidth;
    var h = tmx.height * tmx.tileHeight;
    var spr = new FlxSprite().makeGraphic(w, h, FlxColor.BLACK);
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

    this.add(spr);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    EventNpc.parent = null;
    EventNpc.isCollision = null;
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update():Void {
    super.update();

    if(FlxG.keys.justPressed.ENTER) {
      EventNpc.forEach(playerID, function(npc:EventNpc) {
        npc.requestWalk(Dir.Down);
      });
    }

    // デバッグ処理
    updateDebug();
  }

  private function updateDebug():Void {
#if neko
    if(FlxG.keys.justPressed.ESCAPE) {
      throw "Terminate.";
    }
#end
    // デバッグ処理
    if(FlxG.keys.justPressed.R) {
      FlxG.switchState(new OpeningState());
    }
  }
}
