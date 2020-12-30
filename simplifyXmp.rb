#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'nkf'
require 'pp'
#require 'rexml/document'
matchDataPart = ''
xmpStart = '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core 5.6-c140 79.160451, 2017/05/06-01:08:21        ">'
targetFile = ARGV.shift

File.open(targetFile, 'r') do |fileOpen|
	utf8 = NKF::nkf( "-wm0", fileOpen.read )
	matchData = utf8.split(xmpStart)
	matchDataPart = matchData[-1].unicode_normalize(:nfc)
	#doc = REXML::Document.new(utf8)
end
#pp matchDataPart

File.open(targetFile, 'w') do |fileOpen|
	fileOpen.write(xmpStart + matchDataPart)
end