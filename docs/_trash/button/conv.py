#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

def conv(name, idx):
	# 背景
	back = "src/back%d.png"%idx
	# アイコン
	icon = "src/%s.png"%name
	# 出力ファイル
	dst = "tmp%d.png"%idx

	ofs = 0
	if idx == 3:
		ofs = 1

	# コマンド文字列作成
	cmd = "/opt/ImageMagick/bin/convert -geometry 32x32+%d+%d %s %s -composite %s"%(ofs, ofs, back, icon, dst)
	print cmd

	# 実行
	os.system(cmd)

	# カーソル
	cursor = ""
	if idx == 2:
		cursor = "src/select.png"
		# コマンド文字列作成
		cmd = "/opt/ImageMagick/bin/convert %s %s -composite %s"%(dst, cursor, dst)
		print cmd

		# 実行
		os.system(cmd)


tbl = ["weapon", "armor", "ring", "food", "potion", "wand", "scroll", "orb"]
for name in tbl:
	for i in range(1, 3+1):
		conv(name, i)
	cmd = "/opt/ImageMagick/bin/convert +append tmp1.png tmp2.png tmp3.png out/%s.png"%name
	print cmd
	os.system(cmd)
