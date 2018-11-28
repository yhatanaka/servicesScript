#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'

ARGV.each do |targetFile|
	targetFileDir = File.dirname(targetFile)
	targetFileName = File.basename(targetFile)
#	if targetFileName =~ /([0-9][0-9])([0-9][0-9]#.*)/
	if targetFileName =~ /([0-9]{2})([0-9]{2})([0-9]{2})_(.*)/
		newFilename = '20' + $1 +'-' + $2 + '-' + $3 +'_' + $4
		p newFilename
		File.rename(targetFileDir + '/' + targetFileName, targetFileDir + '/' + newFilename)
	end #if
#	p targetFile
end #each