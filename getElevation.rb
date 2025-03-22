#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# 

require 'csv'
require 'pp'
require 'open-uri'
require "json"

inputFile = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring_join.csv'
inputCsv = CSV.read(inputFile, headers: true)
outputCSV = CSV::Table.new([])
inputCsv.each {|row|
	lonlatAry = [row['lon'], row['lat']]
	elevURI = "https://cyberjapandata2.gsi.go.jp/general/dem/scripts/getelevation.php?lon=#{lonlatAry[0]}&lat=#{lonlatAry[1]}&outtype=JSON"
	elevJSON = JSON.parse(URI.open(elevURI).read)
	elevJSON.each {|idx, n|
		row[idx] = n
	}
	outputCSV << row
	pp elevJSON
	sleep(1)
}

IO.write('/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring_join_w_elev.csv', outputCSV.to_s)
