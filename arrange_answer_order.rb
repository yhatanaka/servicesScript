#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
# 選択問題の解答の記号の後に、語群の文字列をくっつける
# = 語群の文字列を、解答の順番に並べ替える
# require 'csv'
require 'pp'
# inputFile = ARGV.shift
# puts File.read(inputFile)
#inputFile = ARGV.shift
#inputTxt = File.read(inputFile)
#input = CSV.read(inputFile, headers: false)
#input = File.readlines(inputFile)

answerTxt = <<EOS
セ
ヌ
ク
テ
チ
ヌ
シ
オ
ア
ウ
エ
タ
ソ
コ
イ
ナ
ネ
ニ
サ
ケ
EOS

listTxt = <<EOS
ア. 1気圧
イ. 273
ウ. 0℃
エ. 100℃
オ. ℃
カ. J/K
キ. J/(g・K)
ク. 拡散
ケ. カロリー
コ. ケルビン
サ. ジュール
シ. セルシウス
ス. ワット
セ. ブラウン
ソ. 絶対温度
タ. 絶対零度
チ. 増加
ツ. 大きい
テ. 大きく
ト. 等しく
ナ. 熱
ニ. 熱量
ヌ. 熱運動
ネ. 熱平衡
EOS

separater = '. '
joinTxt = ' '

# listTxt をまず行に分割し、各行を separater で2つに分割したものを Hasah に
listHash = listTxt.split("\n").each_with_object({}) {|aRow, hash|
	hash[aRow.split(separater)[0]] = aRow.split(separater)[1]
}

# answerTxt を行に分割し、行ごとにjoinTxt と listHash の項目(つまり語群の文字列)を連結して出力
answerTxt.split("\n").each {|aRow|
	puts aRow + joinTxt + listHash[aRow]
}

#pp answerModAry
exit
# answerTxt を行に分割し、配列に
answerOrigAry = answerTxt.split("\n")
# 各要素に、joinTxt と listHash の項目(つまり語群の文字列)を連結
answerModAry = answerOrigAry.each_with_object([]) {|aRow, ary|
	ary << aRow + joinTxt + listHash[aRow]
}

#listHash = {}
## tab,改行で配列に分ける
#listTxt.split("\n").each {|aRow|
#	listHash[aRow.split(separater)[0]] = aRow.split(separater)[1] 
#}


# tab区切りで出力
resultCSV.each {|aRow|
	puts aRow.join("\t")
}
