#!/usr/bin/ruby

# "カレンダー"からコピーしたイベントをペーストしたテキストファイルを，timeline2で読み込めるcsvに変換

require 'date'
require 'pp'
require 'csv'

headerArray = ['Start Date','End Date','Event Title']
outputArray = Array.new
outputCSVString = CSV::generate_line(headerArray)

open(ARGV.shift,'r') do |inFile|
	eventArray = Array.new(3)
	inFile.each do |line|
		if /^予定日: (201[0-9])\/([01][0-9])\/([0-3][0-9]) ([0-9:]+)〜([0-9:]+)/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + $4 + ':00'
			eventArray[1] = $1 + '-' + $2 + '-' + $3 + ' ' + $5 + ':00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /^予定日: (201[0-9])\/([01][0-9])\/([0-3][0-9])〜(201[0-9])\/([01][0-9])\/([0-3][0-9])/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + '00:00'
			eventArray[1] = $4 + '-' + $5 + '-' + $6 + ' ' + '24:00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /^予定日: (201[0-9])\/([01][0-9])\/([0-3][0-9])/.match(line)
			eventArray[0] = $1 + '-' + $2 + '-' + $3 + ' ' + '00:00'
			eventArray[1] = $1 + '-' + $2 + '-' + $3 + ' ' + '24:00'
			outputCSVString << CSV::generate_line(eventArray)
		elsif /場所: (.+)/.match(line)
		elsif /〒.+/.match(line)
		else
			eventArray[2] = line.rstrip
		end #if
	end # inFile.each
end # do inFile
print outputCSVString