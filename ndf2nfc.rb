#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'nkf'
require 'pp'

targetDir = ARGV.shift
execFlag = ARGV.shift

#pp targetDir
# カレントディレクトリの
#Dir::foreach(targetDir) do |filename|
#	pp filename
#end #foreach

#p targetDir
# 対象ディレクトリの中のxmpファイルを再帰的に検索，結果をArrayに
dir_entries = Dir.glob(targetDir + '/' + '**/*' + '\.xmp').sort
#pp dir_entries

resultAry = []
dir_entries.each do |aFile|
	pp aFile
	File.open(aFile, 'r') do |aFileContent|
# NFDをNFCにして書き戻す
		aFileContentOrig = aFileContent.read
		convertedToNdc = aFileContentOrig.unicode_normalize(:nfc)
#		if convertedToNdc == aFileContentOrig
		if convertedToNdc != aFileContentOrig
#			aFileContent.puts(convertedToNdc)
			resultAry.puts(aFile)
		end #if
	end #open

end  #each

pp resultAry