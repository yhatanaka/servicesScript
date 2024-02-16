#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
testFlag = ARGV.shift
#puts targetDir
#exit
Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)

	newFileName = ''
	fileFlag = true

# IMG_0969_コオニヤンマ幼虫遊佐高.jpg
# → コオニヤンマ幼虫_IMG_0969_遊佐高.jpg
	if filename =~ /([0-9A-Z_\-]*)_([^0-9A-Z_\-]*)(遊佐高)\.jpg/
		newFileName = $2 + '_' + $1 + '_' + $3 + '.jpg'
# 2010-06-25__DSC6253_オオコオイムシ.jpg
# → オオコオイムシ_2010-06-25__DSC6253.jpg
	elsif filename =~ /([0-9A-Z_\-]*)_([^0-9A-Z_\-]*)\.jpg/
		newFileName = $2 + '_' + $1 + '.jpg'
# ヒットしない場合
	else
		newFileName = '!!!!!' + filename
		fileFlag = false
	end #if

# 最後に'test' つけたら、変更後のファイル名を表示
	if testFlag == 'test'
		pp newFileName
# 'test' なしで、しかもヒット(newFileName 設定成功)していたら
	elsif testFlag.nil? && fileFlag
		File.rename(targetDir + '/' + filename, targetDir + '/' + newFileName)
	end #if
end #foreach