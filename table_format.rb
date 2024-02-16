#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
require 'csv'
require 'pp'
# inputFile = ARGV.shift
# column_num = ARGV.shift.to_i
# column_num = 5
# puts File.read(inputFile)

inputTxt = <<EOS
食	天然	自然	キラーT細胞	記憶キラーT細胞
粘膜	適応	A細胞	樹状細胞	ヘルパーT細胞
好中	細胞	B細胞	形質細胞	記憶ヘルパーT細胞
感染	体液	リンパ節	抗原抗体	マクロファージ
抗体	増殖	特異的	抗原提示
EOS

#inputFile = ARGV.shift
#inputTxt = File.read(inputFile)



inputAry = []
# tab,改行で配列に分ける
inputTxt.split("\n").each {|aRow|
	inputAry << aRow.split("\t")
}

# 接頭辞
#leaderTxt = <<~EOS
#ア
#イ
#ウ
#エ
#オ
#カ
#キ
#ク
#ケ
#コ
#サ
#シ
#ス
#セ
#ソ
#タ
#チ
#ツ
#テ
#ト
#ナ
#ニ
#ヌ
#ネ
#ノ
#ハ
#ヒ
#フ
#ヘ
#ホ
#マ
#ミ
#ム
#メ
#モ
#EOS

leaderTxt = <<~EOS
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
EOS

leaderAry = leaderTxt.split("\n")
sep = '.	'

# input = CSV.read(inputFile, headers: false)
# input = File.readlines(inputFile)

outputArray = Array.new
outputRowAry = []
resultCSV = []

inputAry.each {|aRow|
	aRow.each {|aColumn|
# 接頭辞+接続+項目
		outputRowAry << leaderAry.shift + sep + aColumn
	}
# 	resultCSV << CSV::generate_line(outputRowAry)
# 行を追加し、初期化
	resultCSV << outputRowAry
	outputRowAry = []
}

# tab区切りで出力
resultCSV.each {|aRow|
	puts aRow.join("\t")
}
# puts resultCSV

=begin
input.each_with_index { |aRow,rowIdx|
	outputRowAry << leaderAry.shift + sep + aRow.chomp
	if (rowIdx+1)%column_num == 0
		outputAry << outputRowAry
		outputRowAry = []
	end
}
=end


# input.each { |aRow|
# 	aRowAry = []
# 	aRowColumnCount = aRow.size
# 	aRow.each_with_index { |aColumn,column_num|
# 		aRowAry << leaderAry.pop + aColumn
# 		if column_num + 1 == aRowColumnCount
# 			pp aRow
# 		end
# 	}
# }

