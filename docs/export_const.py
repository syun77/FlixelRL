#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlrd
import yaml



# メイン処理
def main(inFile, out):
	# 定数ファイル読み込み
	fConst = open(inFile)
	const = yaml.load(fConst)
	fConst.close()

	txt = "package jp_2dgames.game.item;\n"
	txt += "\n"
	txt += "class ItemConst {\n"
	for k, v in const.items():
		txt += "  public static inline var %s:Int = %d;\n"%(k, v)
	txt += "}\n"

	fOut = open(out, "w")
	fOut.write(txt)
	fOut.close()

	print "export > %s"%(out)

def usage():
	print "Usage: constexport.py [input.txt] [classname] [output]"

if __name__ == '__main__':
	argc = len(sys.argv)
	const = {}
	if argc < 3:
		usage()
		quit()
	main(sys.argv[1], sys.argv[2])
	# main("header_item.txt", "/Users/syun/Desktop/FlixelRL/source/jp_2dgames/game/item/ItemConst.hx")
