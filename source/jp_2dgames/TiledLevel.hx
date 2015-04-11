package jp.seconddgames.natsukiboost3.jp_2dgames;

import jp.seconddgames.natsukiboost3.PlayState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import haxe.io.Path;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledMap;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;

/**
 * TiledMapの読み込みクラス
 **/
class TiledLevel extends TiledMap {
    private static inline var C_PATH_LEVEL_TILESHEETS = "assets/levels/";
    // タイルセットのプロパティ名
    private static inline var PROPERTY_TILESET = "tileset";
    // コリジョン無効のプロパティ
    private static inline var PROPERTY_NOCOLLIDE = "nocollide";
    // オブジェクトレイヤーかどうか
    private static inline var PROPERTY_OBJECT = "object";

    public var foregroundTiles:FlxGroup; // 前面レイヤー（描画用）
    public var backgroundTiles:FlxGroup; // 背面レイヤー（描画用）

    private var collidableTileLayers:Array<FlxTilemap>; // コリジョンレイヤー

    /**
     * コンストラクタ
     * @param tileLevel *.tmxファイルパス
     **/
    public function new(tiledLevel:Dynamic) {

        // *.tmxファイルのロード
        super(tiledLevel);

        // 前面用グループ作成
        foregroundTiles = new FlxGroup();
        // 背景用グループ作成
        backgroundTiles = new FlxGroup();

        // TMXファイルをレイヤーに展開する
        // "layers"にレイヤー情報が格納されている
        for(tileLayer in layers) {

            if(tileLayer.properties.contains(PROPERTY_OBJECT)) {
                // オブジェクトレイヤーは何もしない
                continue;
            }

            // タイルセットとして扱う名前を取得
            var tileSheetName:String = tileLayer.properties.get(PROPERTY_TILESET);
            if(tileSheetName == null) {
                // タイルセットの指定がない
                throw "Error: 'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
            }

            // タイルセットを探す
            var tileSet:TiledTileSet = null;
            for(ts in tilesets) {
                if(ts.name == tileSheetName) {
                    // 同名のタイルセットを見つけた
                    tileSet = ts;
                    break;
                }
            }

            if(tileSet == null) {
                // タイルセットが存在しない
                throw "Error: Tileset '" + tileSheetName + "' not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
            }

            // チップ画像のパスを作成
            var imagePath = new Path(tileSet.imageSource);
            var processedPath = C_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

            // FlxTilemapでCSVレイヤーデータを読み込む
            var tilemap:FlxTilemap = new FlxTilemap();
            // タイルの幅を設定
            // CSVでは設定不要
//            tilemap.widthInTiles = width;
//            tilemap.heightInTiles = height;
            // ロード実行
            tilemap.loadMap(tileLayer.csvData, processedPath, tileSet.tileWidth, tileSet.tileHeight, FlxTilemap.OFF, 1, 1, 1);

            if(tileLayer.properties.contains(PROPERTY_NOCOLLIDE)) {

                // コリジョンなしの場合は背景レイヤー
                backgroundTiles.add(tilemap);
            }
            else {

                // コリジョンありの場合はコリジョンレイヤーに登録
                if(collidableTileLayers == null) {
                    collidableTileLayers = new Array<FlxTilemap>();
                }

                foregroundTiles.add(tilemap);
                collidableTileLayers.push(tilemap);
            }
        }
    }

    /**
     * オブジェクトからインスタンスを生成
     **/
    public function loadObjects(state:PlayState) {
        for(group in objectGroups) {
            for(o in group.objects) {
                _loadObject(o, group, state);
            }
        }
    }

    /**
     * オブジェクトからインスタンスを生成
     * @param o タイルオブジェクト
     * @param g タイルオブジェクトを所属しているグループ
     * @param state 登録するFlxState
     **/
    private function _loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState):Void {

    /*
        var px:Int = o.x;
        var py:Int = o.y;

        // Tiled情報は、左下が原点なので上下位置を反転する
        if(o.gid != -1) {
            py -= g.map.getGidOwner(o.gid).tileHeight;
        }

        switch(o.type.toLowerCase()) {
            case "player_start":
            // プレイヤーのスタート地点
            state.createPlayer(px, py);

        }

        if(65 <= o.gid && o.gid <= 69) {
            var id = (o.gid - 65) + 1;
            state.addEnemy(id, px, py);
        }

        switch(o.gid) {
            case 1:
            state.createPlayer(px, py);

            case 2:
            state.addItem(Item.ID_BANANA, px, py);

            case 3:
            state.addItem(Item.ID_KEY, px, py);

            case 4:
            state.addItem(Item.ID_HEART, px, py);

            case 6:
            state.addItem(Item.ID_POWER, px, py);

            case 20:
            state.addLock(px, py);

            case 23:
            state.addIron(Iron.ID_NORMAL, px, py);

            case 27:
            state.addGoal(px, py);
        }
    */
    }

    /**
     * @param obj 当たり判定をするオブジェクト
     * @param notifyCallback ヒット時の処理
     * @param processCallback 当たり判定処理関数
     * @return 当たっていればtrue
     **/
    public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool {

        if(collidableTileLayers == null) {
            // コリジョンがないので判定不要
            return false;
        }

        if(processCallback == null) {
            processCallback = FlxObject.separate;
        }

        for(map in collidableTileLayers) {
            if(FlxG.overlap(map, obj, notifyCallback, processCallback)) {
                // 当たった
                return true;
            }
        }

        // 当たっていない
        return false;
    }
}