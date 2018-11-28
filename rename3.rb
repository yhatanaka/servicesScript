#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# 〜.jpeg を 〜.jpg に
	if filename =~ /(.+)\.jpeg/
		puts $1 + '.jpg'
		File.rename(targetDir + '/' + filename, targetDir + '/' + $1 + '.jpg')
#		puts filename
	end #if
end #foreach