# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
require 'rexml/xpath'
require 'csv'
require 'pp'

flag = ARGV.shift
#inputFile = ARGV.shift
inputFile = '/Users/hatanaka/Dropbox/qgis/2024-11-30_看板/export.kml'
doc = REXML::Document.new(File.new(inputFile))

#headerArray = ['place_name','lon','lat'] + extDataHeaderAry + ['description']
#outputCSVString = CSV::generate_line(headerArray)
##outputCSVString = ''
#outputArray = Array.new(4)

headersAry = [:name,:経度,:緯度]

# その行で新しく追加になった列名を、元のtableにも追加
#addHeaders = aRow.headers - aTable.headers
#addHeaders.each {|addHeaderName|
#	aTable[addHeaderName] = ''
#}
#aTable << aRow

rowAry = []
rowHeadersAry = []
#doc.elements.each('//Folder/') do |area|
#	description = area.elements['name'].text
#	area.each_element('Placemark') do |aPlace|
	doc.elements.each('//Placemark/') {|aPlace|
		placeName = aPlace.elements['name'].text
		if aPlace.elements['Point/coordinates']
			placeCoordAry = aPlace.elements['Point/coordinates'].text.strip.split(',')
		else
			placeCoordAry = ['','']
		end #if
#		outputArray = [placeName,placeCoordAry[0],placeCoordAry[1]]
		aRow = CSV::Row.new(headersAry, [placeName,placeCoordAry[0],placeCoordAry[1]])
# ExtendedData (qgis)
#		aPlace.elements.each('ExtendedData/Data') {|extData|
		aPlace.elements.each('ExtendedData//SimpleData') {|extData|
			idx = extData.attribute('name').value.to_sym
			value = extData.text
#			if extData.attribute('name').value == '通し��'
#				idx = '通しNo.'
#				value = value.to_i
#			end #if
#			if extData.attribute('name').value == '修正の 必要性'
#				idx = '修正の必要性'
#			end #if
			aRow[idx] = value
		}
		rowAry << aRow
# ヘッダ名の和集合
		rowHeadersAry = rowHeadersAry | aRow.headers
	} #each

# 各行のヘッダの和集合から全体のtable作り、各行を加える
	headerRow = CSV::Row.new(rowHeadersAry, [], header_row: true)
	aTable = CSV::Table.new([headerRow])
#pp aTable
	rowAry.each {|row|
		newRowAry = []
		rowHeadersAry.each {|column|
			if row[column]
				newRowAry << row[column]
			else
				newRowAry  << ''
			end #unless
		}
		aTable << newRowAry
	}
#	aTable.push(*rowAry)
#end #each //Folder/
#print outputCSVString

#pp aTable
print aTable.to_csv
