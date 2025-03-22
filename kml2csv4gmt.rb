# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
require 'rexml/xpath'
require 'csv'
require 'pp'

inputFile = ARGV.shift
doc = REXML::Document.new(File.new(inputFile))

# kml ファイル中の緯度、経度、地名、エリア名(国名)のカラム
#headerArray = ['lat','lon','place_name','area_name']
#outputCSVString = CSV::generate_line(headerArray)
outputCSVString = ''
outputArray = Array.new(4)

doc.elements.each('//Folder/') do |area|
	areaName = area.elements['name'].text
	area.each_element('Placemark') do |aPlace|
		placeName = aPlace.elements['name'].text
		placeCoordAry = aPlace.elements['Point/coordinates'].text.strip.split(',')
		outputArray = [placeCoordAry[0],placeCoordAry[1],placeName,areaName]
		outputCSVString << CSV::generate_line(outputArray)
#		outputCSVString << CSV::generate_line(outputArray, col_sep: ' ')
	end #each
#	outputArray[0] = wpt.attribute('lat').value
#	outputArray[1] = wpt.attribute('lon').value
#	outputArray[2] = wpt.elements['place_name'].text
#	outputCSVString << CSV::generate_line(outputArray)
end
print outputCSVString