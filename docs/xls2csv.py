#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlrd
import yaml

# コンバート実行
def conv(sheet, outFile, const):
	print " [sheet] %s ... "%(sheet.name)

	nrows = sheet.nrows
	ncols = sheet.ncols
	row = 0
	ret = ""
	while row < nrows:
		col = 0
		while col < ncols:
			if col > 0:
				ret += ","
			v = sheet.cell(row, col).value
			try:
				# 数値
				ret += str(int(v))
				#print v,
			except:
				# 文字列
				val = str(v.encode("utf-8"))
				if val in const:
					# 定数に置き換え
					val = str(const[val])
				ret += val
				#print val
			col += 1
		row += 1
		#print
		ret += "\n"

	f = open(outFile, "w")
	f.write(ret)
	f.close
	print "   -> %s"%outFile


# メイン処理
def main(inFile, out, const):
	print "target: %s"%(inFile)
	book = xlrd.open_workbook(inFile)
	for sheet in book.sheets():
		conv(sheet, "%s/%s.csv"%(out, sheet.name), const)
	print "done."

def usage():
	print "Usage: xls2csv.py [input.xlsx] [output] [header.txt]"

if __name__ == '__main__':
	argc = len(sys.argv)
	const = {}
	if argc < 3:
		usage()
		quit()
	if argc >= 4:
		# 定数ファイル読み込み
		for fHeader in sys.argv[3].split(","):
			f = open(fHeader)
			const.update(yaml.load(f))
			f.close
	main(sys.argv[1], sys.argv[2], const)
	# main("enemy.xlsx", "/Users/syun/Desktop/FlixelRL/assets/levels/enemy.csv")
