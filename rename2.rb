#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
#puts targetDir
#exit
i=0
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
# 先頭に「○」「△」「□」つけて，あれば連番付け替え，「畠中」つける
#	if filename =~ /([0-9]+_)?(.*\.jpe?g)/
	if filename =~ /○(.*\.jpe?g)/
#		puts $1.to_s + ' : ' + $2
		i = i+1
#puts targetDir + '/' + '○_' + sprintf("%03d", i) + '_' + $2
puts targetDir + '/' + '△' + $1
		File.rename(filename, targetDir + '/' + '□' + $1)
#		File.rename(filename, targetDir + '/mod/' + '○_' + sprintf("%03d", i) + '_' + $2)
#		puts filename
	end #if
end #foreach