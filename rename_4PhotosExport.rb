#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# Photos.appで書き出した，〜 - 1／(総数) を 〜-1 に
# .jpeg は .jpg に
	if filename =~ /(.+) \- ([0-9]+) ／ [0-9]+\.([a-zA-Z]+)/
		fileExt = $3
		if fileExt == 'jpeg'
			fileExt = 'jpg'
		end #if
		newFilename = $1 + '-' + $2 + '.' + fileExt
		puts newFilename
		File.rename(targetDir + '/' + filename, targetDir + '/' + newFilename)
#		puts filename
	end #if
end #foreach