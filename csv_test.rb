#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"
require 'csv'
require 'pp'
require_relative 'CsvTableUtil.rb'

base_dir = '/Users/hatanaka/Dropbox/ジオパーク/2024_サイト再設定/site_2024-10'
inputFile = "#{base_dir}/Table1-表1_cp.csv"
outputFile = "#{base_dir}/2026-01-09_orig.csv"
table = origTable(inputFile)
table.each {|row|
	if row[:緯度]
		row[:緯度] = row[:緯度].round(5)
	end
}
IO.write(outputFile, table.to_csv(col_sep: ',', write_headers: true))
exit

inputFile = '/Users/hatanaka/Downloads/Ｒ04 認定ガイド名簿【遊佐】/会員-1-表1.csv'
tableKey = [:'氏名']
tableHeadersStr = 'No.,＃,氏名,電話番号,メール,期,遊佐,備　考,遊佐'
tableHeadersAry = tableHeadersStr.split(',').map {|n| n.to_sym}

header_converter = lambda {|h| h.to_sym}
table = CSV.table(inputFile, headers: true, skip_blanks: true, header_converters: header_converter)


unpivoted = unpivot(table, tableKey)
pp unpivoted[1]
pivoted = pivot(unpivoted, tableKey, tableHeadersAry)
pp pivoted[1]

