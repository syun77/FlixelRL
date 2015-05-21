#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlrd

def main(inFile, outFile):
	book = xlrd.open_workbook(inFile, outFile)
	sheet = book.sheet_by_index(0);
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
				ret += str(int(v))
				print v,
			except:
				ret += str(v.encode("utf-8"));
				print v.encode("utf-8"),
			col += 1
		row += 1
		print
		ret += "\n"

	f = open(outFile, "w")
	f.write(ret)
	f.close
	print "---------------"
	print "Done."

def usage():
	print "Usage: xls2csv [input.xlsx] [output.csv]"

if __name__ == '__main__':
	argc = len(sys.argv)
	if argc < 3:
		usage()
		quit()
	main(sys.argv[1], sys.argv[2])
	# main("enemy.xlsx", "/Users/syun/Desktop/FlixelRL/assets/levels/enemy.csv")
