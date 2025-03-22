# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
require 'rexml/xpath'
require 'csv'
require 'pp'

#inputFile = ARGV.shift
inputFile = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/遊佐町　湧水　地下水　自噴井戸の電機伝導度分布図.kml'
doc = REXML::Document.new(File.new(inputFile))

# kml ファイル中の経度、緯度、ポイント名、補足、の4カラム
headerArray = ['lon','lat','place_name','description']
outputCSVString = CSV::generate_line(headerArray)
#outputCSVString = ''
outputArray = Array.new(4)

#doc.elements.each('//Folder/') do |area|
#	description = area.elements['name'].text
#	area.each_element('Placemark') do |aPlace|
	doc.elements.each('//Placemark/') do |aPlace|
		placeName = aPlace.elements['name'].text
		placeCoordAry = aPlace.elements['Point/coordinates'].text.strip.split(',')
		description = ''
		if aPlace.elements['description']
			description = aPlace.elements['description'].text
		end #if
		outputArray = [placeCoordAry[0],placeCoordAry[1],placeName,description]
		outputCSVString << CSV::generate_line(outputArray)
#		outputCSVString << CSV::generate_line(outputArray, col_sep: ' ')
	end #each
#	outputArray[0] = wpt.attribute('lat').value
#	outputArray[1] = wpt.attribute('lon').value
#	outputArray[2] = wpt.elements['place_name'].text
#	outputCSVString << CSV::generate_line(outputArray)
#end #each //Folder/
print outputCSVString