# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'csv'
require 'pp'

targetDir = ARGV.shift

nameAry = []
normalizedNameAry = []

# 種類
envatoType = ['3docean', 'audiojungle', 'codecanyon', 'graphicriver', 'photodune', 'themeforest', 'videohive']
# type => {名前 => [〜,〜,…]}
envatoTypeHash = {'3docean' => {}, 'audiojungle' => {}, 'codecanyon' => {}, 'graphicriver' => {}, 'photodune' => {}, 'themeforest' => {}, 'videohive' => {}}

# まずファイル名一覧
# codecanyon-W9uCnMDC-gridbuilder-x-frontend-filterable-elementor-post-grid-builder-file-and-license
Dir::foreach(targetDir) do |filename|
# '-file-and-license'がついているもの
	if filename =~ /(.+)-file-and-license/
		filename2 = $1
		filenameAry = filename2.split('-')
		fileType = filenameAry.shift # 'codecanyon'
		fileUnique = filenameAry.shift # 'W9uCnMDC'
		filename3 = filenameAry.join('-') # 'gridbuilder-x-frontend-filterable-elementor-post-grid-builder'
# 表示用に、Hashにつっこんどく
		if envatoTypeHash[fileType][filename3]
			envatoTypeHash[fileType][filename3] << fileUnique
		else
			envatoTypeHash[fileType][filename3] = [fileUnique]
		end #if
		File.rename(targetDir + '/' + filename, targetDir + "/#{fileType}_#{filename3}_#{fileUnique}" ) # ファイル名、個別識別子を最後にして、名前順にしたときに重複ファイル見つけやすく
	end #if
end #foreach

envatoTypeHash.each {|type, fileHash|
	puts type
	fileHash.each {|fileDescrpt, fileAry|
		if fileAry.size > 1 # 重複あるものを表示
			puts "    #{fileDescrpt}"
			fileAry.each {|eachFileUnique|
				puts "        #{eachFileUnique}"
			} #each
		end #if
	}
#pp fileHash
}

#pp fileHash
