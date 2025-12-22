#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
# 解答の文字列を、語群の記号に変換
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

# 解答(文字列)
answerTxt = <<EOS
熱容量
ジュール毎ケルビン
比熱
にくく
にくい
熱伝導
熱い
断熱材
対流
小さい
空気
対流
放射
赤外線
反射
摩擦
熱
保存
熱運動
熱
運動
燃焼
熱機関
排出
熱
持続可能
回生ブレーキ
熱
化石燃料
二酸化炭素
廃棄
原子力
EOS

# 解答の語群
answerOption = <<EOS
熱	燃焼	高い	熱容量	原子力
比熱	排出	熱い	熱伝導	持続可能
対流	運動	小さい	熱運動	化石燃料
空気	廃棄	にくい	熱機関	回生ブレーキ
放射	保存	にくく	断熱材	二酸化炭素
反射	摩擦	赤外線	ジュール毎ケルビン	
EOS

prefixTxt = <<EOS
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

# answerOption を分割
answerOptinAry = answerOption.split(/[\n\t]/)
answerOptinDupAry = answerOptinAry - answerOptinAry.uniq
# 解答の選択肢、重複チェック
if answerOptinDupAry.size == 0
# 各選択肢がなんの記号になるかのHash
	answerOptinHash = answerOptinAry.each_with_object({}) {|aRow, hash|
		hash[aRow] = prefix.shift
	}
# 文字列での解答に、prefix 付ける
	answerTxt.split("\n").each {|aAnswer|
		# puts "#{answerOptinHash[aAnswer]}#{joinTxt}#{aAnswer}"
		puts "#{answerOptinHash[aAnswer]}"
	}
else
	puts '解答の選択肢に、重複した項目があります'
	pp answerOptinDupAry
end

