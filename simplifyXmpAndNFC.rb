#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'nkf'
require 'pp'
#require 'rexml/document'





targetDir = ARGV.shift
# 対象ディレクトリの中のxmpファイルを再帰的に検索，結果をArrayに
dir_entries = Dir.glob(targetDir + '/' + '**/*' + '\.xmp').sort
#pp dir_entries

matchDataPart = ''
xmpStart = '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="Adobe XMP Core 5.6-c140 79.160451, 2017/05/06-01:08:21        ">'

dir_entries.each do |aFile|
	pp aFile
	File.open(aFile, 'r') do |fileOpen|
		utf8 = NKF::nkf( "-wm0", fileOpen.read )
		matchData = utf8.split(xmpStart)
		matchDataPart = matchData[-1].unicode_normalize(:nfc)
	end

	File.open(aFile, 'w') do |fileOpen|
		fileOpen.write(xmpStart + matchDataPart)
	end

end  #each

