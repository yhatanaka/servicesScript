# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
require 'rexml/xpath'
require 'csv'
require 'pp'

flag = ARGV.shift
#inputFile = ARGV.shift
inputFile = '/Users/hatanaka/Dropbox/qgis/2024-11-30_看板/ジオ看板20241022新規.kml'
doc = REXML::Document.new(File.new(inputFile))

if flag == 'chk'
	headerAry = []
	doc.elements.each('//Placemark/') {|aPlace|
		extDataNameAry = []
		aPlace.elements.each('ExtendedData/Data') {|extData|
			extDataNameAry << extData.attribute('name').value
		}
		pp extDataNameAry
#		headerAry = headerAry | extDataNameAry
	} #each
#	pp headerAry
else
# kml ファイル中の経度、緯度、ポイント名、補足、の4カラム
#extDataHeaderAry = ["通し��", "種類", "サイト", "エリア", "緯度", "経度", "翻訳（英）", "翻訳（中）", "翻訳（韓）", "設置年度", "設置者", "土地所有者", "修正の 必要性", "修正の必要性の理由"]
#headerArray = ['place_name','lon','lat'] + extDataHeaderAry + ['description']
#outputCSVString = CSV::generate_line(headerArray)
##outputCSVString = ''
#outputArray = Array.new(4)

headersAry = ['place_name','lon','lat']
#headersAry = ['place_name','lon','lat','description']

#aRow = CSV::Row.new(headersAry, ['row1_1','row1_2','row1_3'])
#aRow['extra'] = 'testtest'
#pp aTable.headers
#pp aRow.headers

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
# ExtendedData
		aPlace.elements.each('ExtendedData/Data') {|extData|
			idx = extData.attribute('name').value
			value = extData.elements['value'].text
			if extData.attribute('name').value == '通し��'
				idx = '通しNo.'
				value = value.to_i
			end #if
			if extData.attribute('name').value == '修正の 必要性'
				idx = '修正の必要性'
			end #if
			aRow[idx] = value
		}

		description = ''
		if aPlace.elements['description']
			description = aPlace.elements['description'].text
		end #if
		aRow['description'] = description
		rowAry << aRow
# ヘッダ名の和集合
		rowHeadersAry = rowHeadersAry | aRow.headers
	} #each
# 各行のヘッダの和集合から全体のtable作り、各行を加える
	headerRow = CSV::Row.new(rowHeadersAry, [], header_row: true)
	aTable = CSV::Table.new([headerRow])
	aTable.push(*rowAry)
#end #each //Folder/
print aTable.to_csv
#print outputCSVString
end #if