#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
require 'csv'
require 'pp'
 inputFile = ARGV.shift
 column_num = ARGV.shift.to_i
# column_num = 2
# puts File.read(inputFile)

#inputTxt = <<EOS
#	一次	側鎖	アミノ基
#	カルボキシ基	αヘリックス構造	βシート構造
#	三次	四次	失活
#	DNAヘリカーゼ	DNAポリメラーゼ	リーディング鎖
#	ラギング鎖	岡崎フラグメント	DNAリガーゼ
#	複製	セントラルドグマ	転写
#	翻訳	転写	mRNA
#	tRNA	翻訳	リボソーム
#	RNAポリメラーゼ	プロモーター	センス鎖
#	U	アンチセンス鎖	スプライシング
#	選択的スプライシング	
#EOS

#inputFile = ARGV.shift
inputTxt = File.read(inputFile)



inputAry = []
# tab,改行で配列に分ける
inputTxt.split("\n").each {|aRow|
#	inputAry << aRow.split("\t")
	aRow.split("\t").each {|aColumn|
		inputAry << aColumn
	}
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

#leaderAry = leaderTxt.split("\n")
#sep = '.	'
sep = '	'

# input = CSV.read(inputFile, headers: false)
# input = File.readlines(inputFile)

outputAry = Array.new
outputRowAry = []
resultCSV = []

=begin

inputAry.each {|aRow|
	aRow.each {|aColumn|
# 接頭辞+接続+項目
#		outputRowAry << leaderAry.shift + sep + aColumn
		outputRowAry << sep + aColumn
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
=end

inputAry.each_with_index { |aRow,rowIdx|
#	outputRowAry << leaderAry.shift + sep + aRow.chomp
	outputRowAry << aRow.chomp
	if (rowIdx+1)%column_num == 0
#		outputAry << outputRowAry
		resultCSV << CSV::generate_line(outputRowAry)
		outputRowAry = []
	end
}

puts resultCSV

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

