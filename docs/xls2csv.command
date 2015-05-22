#!/bin/sh

# 現在のディレクトリをカレントディレクトリに設定
cd `dirname $0`

# コンバート実行
# 敵データ
python xls2csv.py enemy.xlsx ../assets/levels/enemy.csv
# プレイヤーデータ
python xls2csv.py player.xlsx ../assets/levels/player.csv

# ターミナルを閉じる
killall Terminal
