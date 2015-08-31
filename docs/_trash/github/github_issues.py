#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import urllib2
import codecs

SAVE_FILE = "issues.txt"

def main():

  print "request start."
  # リクエストURL
  url = "https://api.github.com/repos/syun77/FlixelRL/issues"
  print url
  # API接続
  response = urllib2.urlopen(url)
  res = response.read()
  # JSONデコード
  data = json.loads(res)
  # 保存用の文字
  ret = ""
  for data2 in data:
    # タイトル
    title = data2["title"]
    #title = title.encode("s-jis")
    # 番号
    number = data2["number"]
    labels = u""
    for label in data2["labels"]:
      # ラベル
      labels += u"[%s]"%(label["name"])
    #labels = labels.encode("s-jis")
    
    # 出力
    ret += u"#%s %s%s\n"%(number, labels, title)
    
  f = codecs.open(SAVE_FILE, "w", "utf-8")
  f.write(ret)
  f.close
  
  print "Done."

main()
