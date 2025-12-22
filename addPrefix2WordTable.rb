#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
# 表形式の解答語群の前に、記号の文字列を連結
# 
require 'csv'
require 'pp'
# inputFile = ARGV.shift
# puts File.read(inputFile)
#inputFile = ARGV.shift
#inputTxt = File.read(inputFile)
#input = CSV.read(inputFile, headers: false)
#input = File.readlines(inputFile)


# ret = Array.new(40) {|i|
# 	"a#{i + 1}" 
# }

answerOption = <<EOS
熱	燃焼	高い	熱容量	原子力
比熱	排出	熱い	熱伝導	持続可能
対流	運動	小さい	熱運動	化石燃料
空気	廃棄	にくい	熱機関	回生ブレーキ
放射	保存	にくく	断熱材	二酸化炭素
反射	摩擦	赤外線	ジュール毎ケルビン	
EOS

prefixTxt = <<~EOS
ア
イ
ウ
エ
オ
カ
キ
ク
ケ
コ
サ
シ
ス
セ
ソ
タ
チ
ツ
テ
ト
ナ
ニ
ヌ
ネ
ノ
ハ
ヒ
フ
ヘ
ホ
マ
ミ
ム
メ
モ
ヤ
ユ
ヨ
ラ
リ
ル
レ
ロ
ワ
EOS

prefix = prefixTxt.split("\n")
# prefix = ('a'..'z').to_a
# prefix = ('A'..'Z').to_a
# prefix = ('1'..'50').to_a

separater = "\t"
joinTxt = '. '

# answerOption をまず行に分割し、各行を separater で分割したものを Array に
answerOption.split("\n").each {|aRow|
	# newRow = aRow.split(separater)
	newRow = aRow.split(separater).map {|aItem|
		prefix.shift + joinTxt + aItem
	}
	puts newRow.join(separater)
}