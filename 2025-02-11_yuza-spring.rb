#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# 早坂さんのデータ(から水道除いたもの)から、gmt用に経度・緯度・電気伝導度のtsv吐き出す

require 'csv'
require 'pp'

# No  ,名称,ｐH,EC（μS）,水温（℃）,種類,lon,lat
inputFile = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring_join4gmt.csv'
inputCsv = CSV.read(inputFile, headers: true)
outputFile = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring4gmt.tsv'

getHeaders = ['lon', 'lat', 'EC（μS）']

returnHeaders = ['経度', '緯度', '電気伝導度']
returnHeadersRow = CSV::Row.new(returnHeaders, [], header_row: true)
outputCSV = CSV::Table.new([returnHeadersRow])

inputCsv.each {|row|
	addRow = []
	getHeaders.each {|aHeader|
		addRow << row[aHeader]
	}
	outputCSV << addRow
}


IO.write(outputFile, outputCSV.to_csv(col_sep: "\t", write_headers: false))
#print outputCSV.to_csv(col_sep: "\t")


=begin


=end