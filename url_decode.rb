#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'uri'

enc = '5602_1_%E5%B0%8F%E5%B1%B1%E5%B4%8E%E9%81%BA%E8%B7%A1%E7%AC%AC8%EF%BD%9E11%E6%AC%A1%E8%AA%BF%E6%9F%BB%E6%A6%82%E8%A6%81%E5%A0%B1%E5%91%8A%E6%9B%B8'
# p URI.decode_www_form_component(enc)

require 'fileutils'
targetDir = ARGV.shift
testFlag = ARGV.shift
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)

# 拡張子
	extname = File.extname(filename)
	if extname == ''
# 	'.', '..'
		fileFlag = false
	else
# ファイル
		fileFlag = true
	end #if

	basename = File.basename(filename,extname)
	newFilename = URI.decode_www_form_component(basename) + extname

# 最後に'test' つけたら、変更後のファイル名を表示
	if testFlag == 'test' && fileFlag
# 		pp extname
		pp newFilename
# 'test' なしなら、ファイル名URLデコード
	elsif testFlag.nil? && fileFlag
		File.rename(targetDir + '/' + filename, targetDir + '/' + newFilename)
	end #if
end #foreach