#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# Photos.appで書き出した，〜 - 1／ほげ.jpeg を 〜-1.jpg に
	if filename =~ /(.+) \- ([0-9]+)\.jpeg/
		if $2.to_i < 10
			newNumber = '0' + $2
		elsif $2.to_i >=10
			newNumber = $2
		end #if
		newFilename = $1 + '-' + newNumber + '.jpg'
		puts newFilename
		File.rename(targetDir + '/' + filename, targetDir + '/' + newFilename)
#		puts filename
	end #if
end #foreach