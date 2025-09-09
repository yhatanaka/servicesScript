#!/usr/bin/ruby
#$KCODE = 'UTF8'
require 'fileutils'
targetDir = ARGV.shift
startNum = ARGV.shift.to_i

testFlag = true
#testFlag = false

#exit

# 対象ディレクトリに移動
Dir.chdir(targetDir)
# ディレクトリ内のファイル、作成日時でソート
sortedFilesAry = Dir.open('.').children.sort_by {|v|
	File.birthtime("#{targetDir}/#{v}")
}

# あるいは、そのまま
#sortedFilesAry = Dir.open('.').children.sort_by {|v|
#	v
#}

#pp sortedFilesAry
sortedFilesAry.each {|aFile|
# 「このファイルはファイル名変換するよ」フラグ
	fileFlag = false
# MP3ファイル
	if File.extname(aFile) == '.mp3'
# ファイル名の先頭につける連番、3桁+0
		prefixNum = sprintf("%03d", startNum) + '0'
# 「.mp3」除いたファイル名
		fileBaseName = File.basename(aFile, '.mp3')
# …が「(数字と-) 曲名」の場合
		if fileBaseName.match(/[0-9\-]+ (.+)/)
			newFileName = "#{prefixNum} #{$1}.mp3"
# ストレートに「曲名」だけの場合
		else
			newFileName = "#{prefixNum} #{fileBaseName}.mp3"
		end
# 「このファイルはファイル名変換するよ」フラグ立てる
		fileFlag = true
		startNum += 1
	else
		pp '!!!!!' + aFile
	end

# テストでは変換後のファイル名表示
	if testFlag
		pp newFileName
# ホンちゃんで、ヒット(newFileName 設定成功)していたら
	elsif fileFlag
#			pp 'not test'
		File.rename("#{targetDir}/#{aFile}", "#{targetDir}/#{newFileName}")
	end #if
}
=begin

Dir::foreach(targetDir) do |filename|
#	newname = filename.gsub(/^(\d+)/, sprintf("%03d", $1.to_i))
#	FileUtils.mv(filename, newname)

	newFileName = ''
	fileFlag = true

if filename.match(/\.mp3/)
origFile = "#{targetDir}/#{filename}"
pp File.birthtime(origFile)
end
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

=end
