#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# 

require 'csv'
require 'pp'

outputFile = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring_test.csv'




def makeXY
	region_w = 139.8
	region_e = 140.08
	region_s = 38.97
	region_n = 39.15
	divLon = 5
	divLat = 5
	roundNum = 4
	lonStep = ((region_e - region_w)/divLon)
	latStep = ((region_n - region_s)/divLat)
	rtnAry = []
	(1..(divLon-1)).each {|iLon|
		(1..(divLat-1)).each {|iLat|
			pLon = (region_w + iLon*lonStep).round(roundNum)
			pLat = (region_s + iLat*latStep).round(roundNum)
			rtnAry << [pLon,pLat,valueFromLonLat(pLon,pLat)]
		}
	}
	return rtnAry
end #def

def valueFromLonLat(lon,lat)
	lonRate = (lon-139.8)/(140.08-139.8)
	latRate = (lat-38.97)/(39.15-38.97)
	value = lonRate/1 + latRate/2 + lonRate*Math.sin(latRate*2*Math::PI)
#	value = lonRate/1 + latRate/2 + 0.5*Math.sin(latRate*2*Math::PI)
	return value.round(2)
end #def

returnHeaders = ['経度', '緯度', '値']
returnHeadersRow = CSV::Row.new(returnHeaders, [], header_row: true)
outputCSV = CSV::Table.new([returnHeadersRow])

#returnHeadersStr = '経度,緯度,値'
#pp CSV.new(returnHeadersStr, header_row: true)
#outputCSV = CSV.new(returnHeadersStr, header_row: true).read


inputAry = makeXY
#pp inputAry

inputAry.each {|row|
	outputCSV << row
}
#outputCSV.push(inputAry)


IO.write(outputFile, outputCSV.to_csv(col_sep: "\t", write_headers: false))
#print outputCSV.to_csv(col_sep: "\t")


=begin


=end