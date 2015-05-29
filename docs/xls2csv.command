#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/levels
# 敵出現テーブル
python xls2csv.py enemy_appear.xlsx ../assets/levels header_enemy.txt
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/levels
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data
# アイテム
python xls2csv.py item.xlsx ../assets/levels

# ターミナルを閉じる
killall Terminal
