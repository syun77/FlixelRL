// ネコを4匹集めた
MSG,18
MSG,19
MSG,20
SE,foot

FADE_OUT,black
MAP_LOAD,010.tmx
// プレイヤー生成
NPC_CREATE,0,player,13,18,down
// プレイヤー移動
NPC_MOVE,0,up,12

// ネコ生成
NPC_CREATE,1,cat,12,16,random
NPC_CREATE,2,cat,15,17,random
NPC_CREATE,3,cat,14,15,random
NPC_CREATE,4,cat,11,20,random
// ネコの色設定
NPC_COLOR,1,0xfffa8072
NPC_COLOR,2,0xFF80A0FF
NPC_COLOR,3,0xffffffff
NPC_COLOR,4,0xffbfff00
// ネコ移動
NPC_MOVE,1,up,10
NPC_MOVE,2,up,10
NPC_MOVE,3,up,10
NPC_MOVE,4,up,11
// ネコ方向設定
NPC_WAIT,1,0.5
NPC_WAIT,2,1
NPC_DIR,1,right
NPC_DIR,2,left
NPC_DIR,3,down
// ランダム移動
NPC_RANDOM,1
NPC_RANDOM,2
NPC_RANDOM,3
NPC_RANDOM,4
FADE_IN,black
MSG,21
MSG,22
MSG,23
SE,pickup
// マタタビ画像表示
IMAGE,matatabi.png
MSG,24
IMAGE_OFF
// 女の子がっかり
NPC_MOVE,0,down,1
MSG,25
// 女の子帰る
NPC_MOVE,0,down,10
MSG,26
// ネコも帰る
NPC_MOVE,1,down,10
NPC_MOVE,2,down,10
NPC_MOVE,3,down,10
NPC_MOVE,4,down,10
FADE_OUT,black
MAP_CLEAR
NPC_DESTROY_ALL
// ダンジョン終わり

// 伝説のマタタビの説明
// マタタビ画像表示
IMAGE,matatabi.png
FADE_IN,black
MSG,27
MSG,28
IMAGE_OFF
MSG,29

// 再び女の子の家
FADE_OUT,black
MAP_LOAD,001.tmx
// 女の子とネコを配置
NPC_CREATE,0,player,13,5,down
// ネコ生成
NPC_CREATE,1,cat,6,4,random
NPC_CREATE,2,cat,18,5,random
NPC_CREATE,3,cat,8,7,random
NPC_CREATE,4,cat,14,6,random
NPC_CREATE,5,cat,2,4,random
NPC_CREATE,6,cat,8,5,random
NPC_CREATE,7,cat,10,7,random
NPC_CREATE,8,cat,19,6,random
NPC_CREATE,9,cat,9,4,random
NPC_CREATE,10,cat,3,5,random
NPC_CREATE,11,cat,20,7,random
NPC_CREATE,12,cat,15,6,random
NPC_CREATE,13,cat,7,4,random
NPC_CREATE,14,cat,21,5,random
NPC_CREATE,15,cat,13,7,random
NPC_CREATE,16,cat,12,6,random
// ネコの色設定
NPC_COLOR,1,0xfffa8072
NPC_COLOR,2,0xFF80A0FF
NPC_COLOR,3,0xffffffff
NPC_COLOR,4,0xffbfff00
NPC_COLOR,5,0xfffa8072
NPC_COLOR,6,0xFF80A0FF
NPC_COLOR,7,0xffffffff
NPC_COLOR,8,0xffbfff00
NPC_COLOR,9,0xfffa8072
NPC_COLOR,10,0xFF80A0FF
NPC_COLOR,11,0xffffffff
NPC_COLOR,12,0xffbfff00
NPC_COLOR,13,0xfffa8072
NPC_COLOR,14,0xFF80A0FF
NPC_COLOR,15,0xffffffff
NPC_COLOR,16,0xffbfff00
// ランダム移動
NPC_RANDOM,1
NPC_RANDOM,2
NPC_RANDOM,3
NPC_RANDOM,4
NPC_RANDOM,5
NPC_RANDOM,6
NPC_RANDOM,7
NPC_RANDOM,8
NPC_RANDOM,9
NPC_RANDOM,10
NPC_RANDOM,11
NPC_RANDOM,12
NPC_RANDOM,13
NPC_RANDOM,14
NPC_RANDOM,15
NPC_RANDOM,16
FADE_IN,black
MSG,30
MSG,31
MSG,32
// TODO:女の子を画像を作る
// MSG,33
// IMAGE,"end.png"
// MSG,34
// MSG,35
// MSG,36
FADE_OUT,white
// スタッフロールへ
