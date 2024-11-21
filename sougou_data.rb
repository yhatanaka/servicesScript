#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# ガイド受付システムからExportしたガイドのCSVファイルから、同姓同名の人がいないかチェック

require 'csv'
require 'pp'

indexAry = [:年月日, :水温, :体長, :group]
checkIndexAry = [:年月日, :水温, :group]
prevHash = {}
outputCSVString = CSV::generate_line(indexAry)

ARGV.each {|inputFile|
	inputCsv = CSV.read(inputFile, headers: true)
	prevRow = {}
	inputCsv.each { |aRow|
		thisRowAryForHash = indexAry.map {|item|
			[item, aRow[item.to_s]]
		}
#		prevRow = {:年月日 => aRow['年月日'], :水温 => aRow['水温'], :体長 => aRow['体長'], :group => aRow['group']}
		thisRowHash = thisRowAryForHash.to_h.compact
		prevHash = prevHash.merge(thisRowHash)
		thisRowAry = indexAry.map {|item|
			prevHash[item]
		}
#		pp thisRowAry
		outputCSVString << CSV::generate_line(thisRowAry)
	}
}

print outputCSVString
exit


=begin

=end