#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
if ARGV.shift == 'rename!'
renameFlag = true
else
renameFlag = false
end #if
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# Aperture でかき出した際に着いた，バイナリ「10」を削除
# http://www.asciitable.com
	if filename =~ /(.*)\020(.*)/
		newFilename = filename.gsub(/\020/,'')
		puts newFilename
if renameFlag
		File.rename(targetDir + '/' + filename, targetDir + '/' + newFilename)
		puts '*** RENAMED!!! ***'
end #if
#		puts filename
	end #if
end #foreach