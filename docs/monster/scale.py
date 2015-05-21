#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

# 入力ファイル
INPUT = "player32x32.png"
# 出力ファイル
OUTPUT = "player96x96point.png"
# 2倍にする
SCALE = 2

# コマンド文字列作成
cmd = "/opt/local/bin/convert -filter box -resize %d%% %s %s"%(SCALE*100, INPUT, OUTPUT)
print cmd

# 実行
os.system(cmd)
