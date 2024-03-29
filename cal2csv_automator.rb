#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

# "カレンダー"からコピーしたイベントをペーストしたテキストファイルを，timeline2で読み込めるcsvに変換

require 'date'
require 'pp'
require 'csv'

headerArray = ['Start Date','End Date','Event Title']
outputArray = Array.new
outputCSVString = CSV::generate_line(headerArray)

ARGV.each do |f|
	eventArray = Array.new(3)
	f.dup.force_encoding("UTF-8").split("\n").each do |line|
		if /^予定日: (20[12][0-9])\/([01][0-9])\/([0-3][0-9]) ([0-9:]+)から([0-9:]+)/.match(line)
# 		if /^予定日: (20[12][0-9])\/([01][0-9])\/([0-3][0-9]) ([0-9:]+)〜([0-9:]+)/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + $4 + ':00'
			eventArray[1] = $1 + '-' + $2 + '-' + $3 + ' ' + $5 + ':00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /^予定日: (20[12][0-9])\/([01][0-9])\/([0-3][0-9])から(20[12][0-9])\/([01][0-9])\/([0-3][0-9])/.match(line)
#		elsif /^予定日: (20[12][0-9])\/([01][0-9])\/([0-3][0-9])〜(20[12][0-9])\/([01][0-9])\/([0-3][0-9])/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + '00:00'
			eventArray[1] = $4 + '-' + $5 + '-' + $6 + ' ' + '24:00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /^予定日: (20[12][0-9])\/([01][0-9])\/([0-3][0-9])/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + '00:00'
			eventArray[1] = $1 + '-' + $2 + '-' + $3 + ' ' + '24:00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /場所: (.+)/.match(line)
		elsif /〒.+/.match(line)
		else
			eventArray[2] = line.rstrip
		end #if
	end # inFile.each
end
puts outputCSVString