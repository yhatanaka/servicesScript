#!/usr/bin/ruby

require "pp"

inputFile = ARGV.shift
input = File.read(inputFile)

# png から jpg に置き換えるファイルのリスト
imgList = <<EOS

2019031600001_2.jpg


EOS

imgListAry = imgList.split("\n").compact
imgListAry.delete('')

searchTagStart = "NeXTGraphic "

imgListAry.each do |aImg|
	imgBaseName = aImg.split('.')[0]
	pngFileName = imgBaseName + '.png'
	jpgFileName = imgBaseName + '.jpg'
	input.gsub!(searchTagStart + pngFileName, searchTagStart + jpgFileName)
end # each





if inputFile
	open(inputFile,'w') do |outFile|
		outFile.write(input)
	end # do outFile
end #if
