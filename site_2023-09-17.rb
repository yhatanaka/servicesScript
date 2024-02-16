# -*- coding: utf-8 -*-
$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

require 'pp'
require 'nokogiri'
require 'csv'

handle = File.open(ARGV.shift)
# handle = File.open(ARGV.shift, "rt:Shift_JIS:UTF-8")
	doc = Nokogiri::HTML(handle)

# pp doc

area_num = -1
areaAry = ['由利本荘', 'にかほ', '遊佐', '酒田', '飛島']

resultCSV = CSV::generate_line(['name', 'area', 'site_type'])

# エリア毎
doc.css('div.inner').each do |anItem1|
	area_num += 1
	site_type = ''
# 	anItem1.traverse do |anItem2|
	anItem1.children.each do |anItem2|
		if anItem2.name == 'h3'
# 		if anItem2['class']  == 'h3 bold'
# サイトタイプ
			site_type = anItem2.css('span.h3').text
# 			puts site_type
		elsif anItem2.name == 'div' && site_type != ''
# サイト名
			lineAry = [anItem2.css('span').text, areaAry[area_num], site_type]
				resultCSV << CSV::generate_line(lineAry)
		end
	end
end

print resultCSV
