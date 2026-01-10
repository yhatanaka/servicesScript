#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# CsvTableUtil テスト
require 'csv'
require 'pp'
require_relative 'CsvTableUtil.rb'

actualTestFlag = true

if actualTestFlag
	require 'minitest/autorun' # Minitest ライブラリを読み込む
else
	base_dir = '/Users/hatanaka/Documents/servicesScript/csv_test'
	inputFile1 = "#{base_dir}/1-test_1.csv"
	inputFile2 = "#{base_dir}/1-test_2.csv" # 縦持ち
	pp unpivotedTable2Data(origTable(inputFile2), [:番号])
	exit

end

class CsvTableUtilTest < Minitest::Test # CsvTableUtilTest クラスを定義、Minitest::Test クラスを継承
	def test_read
		base_dir = '/Users/hatanaka/Documents/servicesScript/csv_test'
		inputFile1 = "#{base_dir}/1-test_1.csv"
		origTblStr = <<EOS
番号,氏名,年齢,変なヤツ
1,名無　権兵衛,51,TRUE
2,普通　野子,30,FALSE
3,南野　誰某,43,TRUE
EOS
		assert_equal origTblStr, origTable(inputFile1).to_s
		assert_equal "番号,氏名,年齢,変なヤツ\n" + "1,名無　権兵衛,51,TRUE\n" + "2,普通　野子,30,FALSE\n" + "3,南野　誰某,43,TRUE\n", origTable(inputFile1).to_s
		assert_equal ["番号", "氏名", "年齢", "変なヤツ"], origHeader(inputFile1)
		assert_equal "番号,name,年齢,idiot\n" + "1,名無　権兵衛,51,TRUE\n" + "2,普通　野子,30,FALSE\n" + "3,南野　誰某,43,TRUE\n", replaceHeaders(inputFile1, [nil,'name',nil,'idiot']).to_s
		assert_equal "番号,氏名\n1,名無　権兵衛\n2,普通　野子\n3,南野　誰某\n", selectTableCol(origTable(inputFile1), [:番号, :氏名]).to_s
		dataH = {{番号: 1} => {氏名: '名無　権兵衛', 年齢: 51, 変なヤツ: 'TRUE'}, {番号: 2} => {氏名: '普通　野子', 年齢: 30, 変なヤツ: 'FALSE'}, {番号: 3} => {氏名: '南野　誰某', 年齢: 43, 変なヤツ: 'TRUE'}}
		assert_equal dataH, pivotedTable2Data(origTable(inputFile1), [:番号])
		unpivotTblStr = <<EOS
番号,otherKey,otherKeysValue
1,氏名,名無　権兵衛
1,年齢,51
1,変なヤツ,TRUE
2,氏名,普通　野子
2,年齢,30
2,変なヤツ,FALSE
3,氏名,南野　誰某
3,年齢,43
3,変なヤツ,TRUE
EOS
		assert_equal unpivotTblStr, unpivot(origTable(inputFile1), [:番号]).to_s
		inputFile2 = "#{base_dir}/1-test_2.csv" # 縦持ち
		assert_equal dataH, unpivotedTable2Data(origTable(inputFile2), [:番号]) 
	end
	
	# def test_diff
	# 	base_dir = '/Users/hatanaka/Documents/servicesScript/csv_test'
	# 	inputFile1 = "#{base_dir}/1-test_1.csv"
	# 	inputFile2 = "#{base_dir}/1-test_1.csv"
	# end
end
exit

tableHeadersStr = 'No.,＃,氏名,電話番号,メール,期,遊佐,備　考,遊佐'
tableHeadersAry = tableHeadersStr.split(',').map {|n| n.to_sym}

header_converter = lambda {|h| h.to_sym}
table = CSV.table(inputFile1, headers: true, skip_blanks: true, header_converters: header_converter)

exit
unpivoted = unpivot(table, tableKey)
pp unpivoted[1]
pivoted = pivot(unpivoted, tableKey, tableHeadersAry)
pp pivoted[1]

{{番号: 1} => {氏名: '名無　権兵衛', 年齢: 51, 変なヤツ: TRUE}, {番号: 2} => {氏名: '普通　野子', 年齢: 30, 変なヤツ: FALSE}, {番号: 3} => {氏名: '南野　誰某', 年齢: 43, 変なヤツ: TRUE}}
{{番号: 1} => {氏名: "名無　権兵衛", 年齢: 51, 変なヤツ: "TRUE"}, {番号: 2} => {氏名: "普通　野子", 年齢: 30, 変なヤツ: "FALSE"}, {番号: 3} => {氏名: "南野　誰某", 年齢: 43, 変なヤツ: "TRUE"}}