#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'pp'

require_relative 'CsvTableUtil.rb'
require_relative 'makeSpeciesCsv4monitering.rb'

actualTestFlag = true

if actualTestFlag
	require 'minitest/autorun' # Minitest ライブラリを読み込む
else
	base_dir = '/Users/hatanaka/Documents/servicesScript/makeSpTest'
	pickFile = "#{base_dir}/locSp.txt"
	pickDepthAry = [0,nil,1]
	fromFile = "#{base_dir}/spList.csv"
origTable(fromFile).each_with_index {|row, idx|
	puts "#{idx}: #{row}"
}
	exit
end


class MakeSpTest < Minitest::Test # Minitest::Test クラスを継承
	def test_convert_to_table()
		base_dir = '/Users/hatanaka/Documents/servicesScript/makeSpTest'
		pickFile = "#{base_dir}/locSp.txt"
		pickDepthAry = [0,nil,1]
		fromFile = "#{base_dir}/spList.csv"
# 階層1,階層3を読み込む
		ret01Ary = [['泥沢', 'モノサシトンボ'], ['泥沢', 'コバネイバゴ'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'カナヘビ'], ['ハッチョウ', 'モリアオガエル'], ['ハッチョウ', 'ハッチョウトンボ']]
# 調査結果
		researchList = File.read(pickFile)
		assert_equal ret01Ary, locSpArys(researchList, pickDepthAry)
# 種名 => [調査地1, 調査地2]
		ret2Hash = {'モノサシトンボ' => ['泥沢'], 'コバネイバゴ' => ['泥沢'], 'モリアオガエル' => ['藤井公園', 'ハッチョウ'], 'カナヘビ' => ['藤井公園'], 'ハッチョウトンボ' => ['ハッチョウ']}
		# assert_equal ret2Hash, makeSp2LocHash(ret01Ary)
		assert_equal ret2Hash, makeSp2LocHash(locSpArys(researchList, pickDepthAry))
# 種名リストの重複チェック
		spTbl = origTable(fromFile)
		assert_equal ['ヤマキマダラヒカゲ'], checkDupSpList(spTbl)
		assert_equal [4, 5], whereSpList(spTbl, 'ヤマキマダラヒカゲ')

		fromFile_nodup = "#{base_dir}/spList_nodup.csv"
		spNodupTbl = origTable(fromFile_nodup)
		assert_equal [], checkDupSpList(spNodupTbl)

# 最終データ
		ret3 = []
		assert_equal ret3, makeSpLocTbl(locSpHash, spTbl、locAry)

	end
end