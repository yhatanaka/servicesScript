#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
require 'csv'
require 'pp'
# inputFile = ARGV.shift
# column_num = ARGV.shift.to_i
column_num = 0
# puts File.read(inputFile)

inputTxt = <<EOS
ソ
ア
イ
オ
テ
コ
エ
カ
キ
シ
カ
キ
ケ
カ
チ
EOS

#inputFile = ARGV.shift
#inputTxt = File.read(inputFile)
#input = CSV.read(inputFile, headers: false)
#input = File.readlines(inputFile)




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
sep = '. '
#sep = '.	'

outputAry = Array.new
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

if column_num > 0
	resultCSV.flatten.each_with_index { |value,idx|
		outputRowAry << value
		if (idx+1)%column_num == 0
			outputAry << outputRowAry
			outputRowAry = []
		end
	}
	resultCSV = outputAry
end #if
=begin
=end

# tab区切りで出力
resultCSV.each {|aRow|
	puts aRow.join("\t")
}
# puts resultCSV



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

