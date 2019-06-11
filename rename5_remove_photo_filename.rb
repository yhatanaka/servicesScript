#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'

ARGV.each do |targetFile|
	targetFileDir = File.dirname(targetFile)
	targetFileName = File.basename(targetFile)
#	if targetFileName =~ /([0-9][0-9])([0-9][0-9]#.*)/
# 'yuza_01_a_IMG_0758' -> 'yuza_01_a'
	if targetFileName =~ /yuza_([0-9]{2}_[ab])_.*\.jpg/
		newFilename = 'yuza_' + $1 + '.jpg'
		p newFilename
		File.rename(targetFileDir + '/' + targetFileName, targetFileDir + '/' + newFilename)
	end #if
#	p targetFile
end #each