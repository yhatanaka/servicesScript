#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
require 'pp'
targetDir = ARGV.shift
actFlag = ARGV.shift

#pp Dir::foreach(targetDir).to_a
#exit
nameAry = []
hitAry = []
noHitAry = []

# まずファイル名一覧
Dir::foreach(targetDir) do |filename|
	nameAry << File.basename(filename, '.*')
end #foreach

Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)
#
#	newFileName = ''
#	fileFlag = false

# hoge-[0-9]{1,2} .数字　のファイル -
	if filename =~ /([0-9A-Za-z_\-]+)\-([0-9]{1,2})\.[a-zA-Z]{3,4}/ && nameAry.include?($1)
#	if filename =~ /([0-9A-Za-z_\-]+)\-([^0-9]{1,2})\.[a-zA-Z]{3,4}/
#		newFileName = $2 + '_' + $1 + '_' + $3 + '.jpg'
		hitAry << filename
		fileFlag = true
		File.rename(targetDir + '/' + filename, targetDir + '/deleted/' + filename) # deleted フォルダに入れる
## 2010-06-25__DSC6253_オオコオイムシ.jpg
## → オオコオイムシ_2010-06-25__DSC6253.jpg
#	elsif filename =~ /([0-9A-Z_\-]*)_([^0-9A-Z_\-]*)\.jpg/
#		newFileName = $2 + '_' + $1 + '.jpg'
# ヒットしない場合
	else
		noHitAry << filename
	end #if

# 最後に'test' つけたら、変更後のファイル名を表示
#	if actFlag == 'act'
#		File.rename(targetDir + '/' + filename, targetDir + '/' + newFileName)
# 'act' 付きで、しかもヒット(newFileName 設定成功)していたら
#	elsif actFlag.nil? && fileFlag
#		puts filename
#	end #if
end #foreach

pp hitAry.sort