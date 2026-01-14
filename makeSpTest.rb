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
origTable(fromFile).each {|row|
	pp row
}
	exit
end


class MakeSpTest < Minitest::Test # Minitest::Test クラスを継承
	def test_convert_to_table()
		base_dir = '/Users/hatanaka/Documents/servicesScript/makeSpTest'
		pickFile = "#{base_dir}/locSp.txt"
		pickDepthAry = [0,nil,1]
		fromFile = "#{base_dir}/spList.csv"
		ret01Ary = [['泥沢', 'モノサシトンボ'], ['泥沢', 'コバネイバゴ'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'カナヘビ'], ['ハッチョウ', 'モリアオガエル'], ['ハッチョウ', 'ハッチョウトンボ']]
		assert_equal ret01Ary, convert_to_table(File.read(pickFile), pickDepthAry)
	end
end