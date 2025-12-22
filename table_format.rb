#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
require 'csv'
require 'pp'
# inputFile = ARGV.shift
column_num = ARGV.shift.to_i
# column_num = 0
# puts File.read(inputFile)

inputTxt = <<EOS
ウ
ヘ
オ
ヒ
ヌ
キ
ハ
エ
ケ
テ
ス
ケ
チ
ク
ナ
ノ
ア
ツ
サ
ア
コ
イ
ソ
カ
ア
タ
ネ
ア
ト
フ
セ
シ
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

=begin
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
=end

outputAry = Array.new
outputRowAry = []
resultCSV = []
rowEndFlag = false

=begin
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
=end

if column_num > 0
	inputAry.flatten.each_with_index { |value,idx|
	# resultCSV.flatten.each_with_index { |value,idx|
		outputRowAry << value
# 最終列では、該当行 outputRowAry のデータを outputAry に加え、outputRowAry を空にし、最終列フラグ立てる
		if (idx+1)%column_num == 0
			outputAry << outputRowAry
			outputRowAry = []
			rowEndFlag = true
		else
			rowEndFlag = false
		end
	}
# 最終列まで行かないうち(最終列フラグ false)だったら、該当行 outputRowAry のデータを outputAry に加える
	unless rowEndFlag
		outputAry << outputRowAry
	end 
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

