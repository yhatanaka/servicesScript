#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# 「.ホゲホゲ~imageoptim.jpg」
	if filename =~ /\.(.*)\~imageoptim\.(.*)/
		puts $1 + '.' + $2
		File.rename(filename, targetDir + $1 + '.' + $2)
		puts filename
	end #if
end #foreach