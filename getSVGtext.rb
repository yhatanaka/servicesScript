# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
handle = File.open(ARGV.shift)
#handle = File.open(ARGV.shift, "rt:Shift_JIS:UTF-8")
doc = REXML::Document.new(handle)

#itemAry = []
REXML::XPath.match(doc, '//text').each {|item|
#	lineAry = []
	item.each {|line|
# 	if outline.attribute('_note')
# 	note = outline.attribute('_note').value
		puts line
#		puts line.text
# 	end
	}
	puts
}
