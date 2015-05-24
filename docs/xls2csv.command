#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/levels/enemy.csv
# 敵出現テーブル
python xls2csv.py enemy_appear.xlsx ../assets/levels/enemy_appear.csv header.txt
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/levels/player.csv
# メッセージデータ
python xls2csv.py message.xlsx ../assets/data/message.csv

# ターミナルを閉じる
killall Terminal
