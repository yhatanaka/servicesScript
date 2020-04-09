#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'nkf'
require 'pp'
require 'nokogiri'

inputFile = "/Users/hatanaka/Downloads/3年理科test.html"
f = File.read(inputFile)

def scanItem(list_item)
#	span_item = list_item.xpath('descendant-or-self::node()/li')
	span_item = list_item.xpath('')
	span_item.each do |each_item|
#		if each_item.xpath('descendant-or-self::node()/ul').count > 0
			pp each_item
#		end #if
	end #each
#		pp span_item
		pp span_item.count

		puts
#	list_item_ary = Array.new
#	list_item.each do |inner_item|
#	list_item.xpath("/self").each do |inner_item|
#		tectext = inner_item.xpath("/span[@class='tectext']")
#		tectext = inner_item.xpath("/span")
#		list_item_ary.push(list_item)
#		pp list_item
#	end #each
#	return list_item_ary
end #def

#ARGV.each do |f|
	htmlObject = Nokogiri::HTML.parse(f, nil)
#	htmlObject.xpath('/ul').inner_text.each do |line|
	htmlObject.xpath('//body/ul/li').each do |line|
#	htmlObject.css('body ul li').each do |line|
		scanItem(line)
#		pp line
	end #each
#end



#pp htmlObject
