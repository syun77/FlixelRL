#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import yaml



# メイン処理
def main(inFile, out):
	# 定数ファイル読み込み
	fConst = open(inFile)
	tbl = yaml.load(fConst)
	fConst.close()

	header = tbl["header"]
	data = tbl["data"]

	txt = "package %s;\n"%(header["package"])
	txt += "\n"
	txt += "class %s {\n"%(header["class"])
	for k, v in data.items():
		txt += "  public static inline var %s:Int = %d;\n"%(k, v)
	txt += "}\n"

	out = "%s/%s.hx"%(out, header["class"])
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
	# main("header_item.txt", "/Users/syun/Desktop/FlixelRL/source/jp_2dgames/game/item")
