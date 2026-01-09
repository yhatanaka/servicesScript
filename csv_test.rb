#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# CsvTableUtil テスト
require 'csv'
require 'pp'
require_relative 'CsvTableUtil.rb'

test4testFlag = false

if test4testFlag
	base_dir = '/Users/hatanaka/Documents/servicesScript/csv_test'
	inputFile = "#{base_dir}/1-test_1.csv"
	puts unpivot(origTable(inputFile), [:番号]).to_s

	exit
else
	require 'minitest/autorun' # Minitest ライブラリを読み込む
end

class CsvTableUtilTest < Minitest::Test # CsvTableUtilTest クラスを定義、Minitest::Test クラスを継承
	def test_read
		base_dir = '/Users/hatanaka/Documents/servicesScript/csv_test'
		inputFile = "#{base_dir}/1-test_1.csv"
		origTblStr = <<EOS
番号,氏名,年齢,変なヤツ
1,名無　権兵衛,51,TRUE
2,普通　野子,30,FALSE
3,南野　誰某,43,TRUE
4,各角　然々,72,FALSE
EOS
		assert_equal origTblStr, origTable(inputFile).to_s
		assert_equal "番号,氏名,年齢,変なヤツ\n" + "1,名無　権兵衛,51,TRUE\n" + "2,普通　野子,30,FALSE\n" + "3,南野　誰某,43,TRUE\n" + "4,各角　然々,72,FALSE\n", origTable(inputFile).to_s
		assert_equal ["番号", "氏名", "年齢", "変なヤツ"], origHeader(inputFile)
		assert_equal "番号,name,年齢,idiot\n" + "1,名無　権兵衛,51,TRUE\n" + "2,普通　野子,30,FALSE\n" + "3,南野　誰某,43,TRUE\n" + "4,各角　然々,72,FALSE\n", replaceHeaders(inputFile, [nil,'name',nil,'idiot']).to_s
		assert_equal "番号,氏名\n1,名無　権兵衛\n2,普通　野子\n3,南野　誰某\n4,各角　然々\n", selectTableCol(origTable(inputFile), [:番号, :氏名]).to_s
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
4,氏名,各角　然々
4,年齢,72
4,変なヤツ,FALSE
EOS
				# assert_equal unpivotTblStr, unpivot(origTable(inputFile), [:番号]).to_s

	end
end
exit

inputFile = '/Users/hatanaka/Downloads/Ｒ04 認定ガイド名簿【遊佐】/会員-1-表1.csv'
tableKey = [:'氏名']
tableHeadersStr = 'No.,＃,氏名,電話番号,メール,期,遊佐,備　考,遊佐'
tableHeadersAry = tableHeadersStr.split(',').map {|n| n.to_sym}

header_converter = lambda {|h| h.to_sym}
table = CSV.table(inputFile, headers: true, skip_blanks: true, header_converters: header_converter)

exit
unpivoted = unpivot(table, tableKey)
pp unpivoted[1]
pivoted = pivot(unpivoted, tableKey, tableHeadersAry)
pp pivoted[1]

