#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

# waypointのGPXファイルをCSVに
# ruby waypoints2csv.rb file > output.csv

require 'rexml/document'
require 'csv'
require 'pp'
require 'csv'

inputFile = ARGV.shift

doc = REXML::Document.new(File.new(inputFile))

# waypoint ファイル中の緯度・経度、番号の他に、種名のカラムつけておく
headerArray = ['lat','lon','point_num','species']
outputCSVString = CSV::generate_line(headerArray)
outputArray = Array.new(4)

doc.elements.each('//gpx/wpt') do |wpt|
	outputArray[0] = wpt.attribute('lat').value
	outputArray[1] = wpt.attribute('lon').value
	outputArray[2] = wpt.elements['name'].text
	outputCSVString << CSV::generate_line(outputArray)
end
print outputCSVString