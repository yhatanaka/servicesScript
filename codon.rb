#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table_format.rb input.txt column_num
require 'csv'
require 'pp'

base = ['U','C','A','G']
#codonAry = []
codonRow = []
codon1stBaseRows = []
codonRows = []

itm1 = 'U'
base.each {|itm1|
	codon1stBaseRows = []
	base.each {|itm3|
		codonRow = []
		base.each {|itm2|
			codonRow << itm1 + itm2 + itm3
		}
		codon1stBaseRows << codonRow
		puts codonRow.join("\t")
	}
	codonRows << codon1stBaseRows
}

exit
pp codonRows

resultCSV = []

inputAry.each {|aRow|
	aRow.each {|aColumn|
# 接頭辞+接続+項目
		outputRowAry << leaderAry.shift + sep + aColumn
	}
 	resultCSV << CSV::generate_line(outputRowAry)
# 行を追加し、初期化
	resultCSV << outputRowAry
	outputRowAry = []
}

# tab区切りで出力
resultCSV.each {|aRow|
	puts aRow.join("\t")
}
