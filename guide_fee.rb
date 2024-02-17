#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_fee.rb test/base/guide
# test: 
# base: 案件を出力
# guide_check: ガイド人数・従事時間・ガイド料の各項目数が同じか
# guide: ガイドごとの支払い金額集計
# ガイド受付システムからExportしたCSVファイルから、ガイドごとの支払い金額集計

require 'csv'
require 'pp'

inputFile = ARGV.shift
#inputFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/2024-02-16_SJIS.csv'
inputFileContents = IO.read(inputFile, encoding: 'SJIS').encode('UTF-8')
#inputFileContents = IO.read(inputFile, encoding: 'SJIS').encode('UTF-8').gsub(/石.　英一/, '石𣘺　英一')

# 必要な列
#headersFile = ARGV.shift
#headersCheckedFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/2024-01-05_column.csv'

#inputCsv = CSV.table(inputFileContents)
header_converter = lambda {|h| h.to_sym}
inputCsv = CSV.parse(inputFileContents, headers: true, header_converters: header_converter)
#inputCsv = CSV.parse(inputFileContents, headers: true, header_converters: :symbol)
#pp inputCsv[1]
#exit

def findOverlap(aCsv)
#重複するヘッダ項目をチェック。各項目の個数を集計し、2回以上出た項目とその回数を表示。重複回避してから処理にかかる。
	headersAry = aCsv.headers
	headersHash = {}
	headersAry.each {|item|
		if headersHash[item].nil?
			headersHash[item] = 1
		else
			headersHash[item] += 1
		end #if
	}
	count = 0
	headersHash.each {|item,value|
		if value > 1
			puts item + ' : ' + value.to_s + ''
			count += 1
		end #if
	}
	puts '重複項目数: ' + count.to_s
	return headersHash
end #def

##ヘッダーを出力。次の「必要な列」を抽出するため。
def printCsvHeaders(aCsv)
	puts aCsv.headers
end #def

# test
if ARGV.include?('test')
	pp findOverlap(inputCsv)
	rowsHash = {}
	inputCsv.each_with_index {|row, idx|
		if row['管理番号'] == '' || row['管理番号'].nil?
			puts "error: #{idx} index is null"
			pp row
		elsif rowsHash[row['管理番号']]
			puts "error: #{idx}"
			pp rowsHash[row['管理番号']]
			pp row
		else
			rowsHash[row['管理番号']] = [idx,row]
		end #if
	}
	#printCsvHeaders(inputCsv)
	exit
end #if

def reqColumns(headersCheckedCsvFile)
# 必要な列
# TRUE,FALSE,…
# 項目1,項目2,…
# 1・2行目取り出し、末尾の改行削除してカンマで分割して2つの配列に
# ['TRUE','FALSE',…],['項目1','項目2',…]
	headersStringAry = File.readlines(headersCheckedCsvFile)[0,2].map {|item| item.chomp.split(',')}
# 項目1,項目2,…
# TRUE,FALSE,…
	headersCsvRow = CSV::Row.new(headersStringAry[1],headersStringAry[0])
	headersCsvTable = CSV::Table.new([headersCsvRow])
	#FALSEの列を削除、TRUEの列名だけ残す
	headersCsvTable.by_col!
	headersCsvTable.delete_if {|column, value|
		value[0] == "FALSE"
	}
	return headersCsvTable.headers
end #def
#pp reqColumns(headersCheckedFile)

reqColumns = ['申込番号', '管理番号', 'エリア', 'エリア名', '団体名', '氏名', 'ガイド実施日', '開始時刻', '終了時刻', '開始時刻2', '終了時刻2', 'モデルコース', '催し等', 'モデルコース2', '支払い方法', '案内人1', '案内人2', '案内人3', '案内人4', '案内人5', '案内人6', '案内人7', '案内人8', 'ガイド完了', 'ガイド時間', 'ガイド時間1', 'ガイド時間2', 'ガイド時間3', 'ガイド時間4', 'ガイド時間5', 'ガイド時間6', 'ガイド時間7', 'ガイド時間8', 'ガイド時間11', 'ガイド時間22', 'ガイド時間33', 'ガイド時間44', 'ガイド時間55', 'ガイド時間66', 'ガイド時間77', 'ガイド時間88', 'ガイド料金', 'ガイド料金2', 'ガイド料金3', 'ガイド料金4', 'ガイド料金5', 'ガイド料金6', 'ガイド料金7', 'ガイド料金8', 'ガイド料金合計', 'キャンセル', 'キャンセル2', '支払い', 'クーポン', 'ガイド料金11', 'ガイド料金22', 'ガイド料金33', 'ガイド料金44', 'ガイド料金55', 'ガイド料金66', 'ガイド料金77', 'ガイド料金88', 'ガイド料金総計', 'ガイド実施日2']
=begin
申込番号
管理番号
エリア
エリア名
団体名
氏名
ガイド実施日
開始時刻
終了時刻
開始時刻2
終了時刻2
モデルコース
モデルコース2
催し等
支払い方法
案内人1
案内人2
案内人3
案内人4
案内人5
案内人6
案内人7
案内人8
ガイド完了
ガイド時間
ガイド時間1
ガイド時間2
ガイド時間3
ガイド時間4
ガイド時間5
ガイド時間6
ガイド時間7
ガイド時間8
ガイド時間11
ガイド時間22
ガイド時間33
ガイド時間44
ガイド時間55
ガイド時間66
ガイド時間77
ガイド時間88
ガイド料金
ガイド料金2
ガイド料金3
ガイド料金4
ガイド料金5
ガイド料金6
ガイド料金7
ガイド料金8
ガイド料金合計
キャンセル
キャンセル2
支払い
クーポン
ガイド料金11
ガイド料金22
ガイド料金33
ガイド料金44
ガイド料金55
ガイド料金66
ガイド料金77
ガイド料金88
ガイド料金総計
ガイド実施日2
=end
#headers = <<EOS
#項目1
#項目2
#EOS
#reqColumns = headers.split(/\R/)

#必要な列だけ、ガイド名入ったもの・催行(⚪︎)・当日キャンセル(▲)取り出す。
def selectCsvColumn3(aCsv,columnsAry)
	aCsv.by_col!
	aCsv.delete_if {|columnName, values|
		!columnsAry.include?(columnName.to_s)
	}
	aCsv.by_row!
	aCsv.delete_if {|aCsvRow|
		aCsvRow[:案内人1].nil?
	}
	aCsv.delete_if {|aCsvRow|
		aCsvRow[:キャンセル] != '〇' && aCsvRow[:キャンセル] != '▲'
	}
	return aCsv
end #def

# '支払い' 優先、nilなら'支払い方法'
#「口座振替」「現金払い」の表記を統一
def payment(aCsv)
	aCsv.each {|aCsvRow|
		payment = aCsvRow[:支払い] || aCsvRow[:支払い方法]
		unless payment.nil?
			if payment.match?(/口座.*|.*振込.*/)
				payment = :口座
			elsif payment.match?(/現金.*/)
				payment = :現金
			end #if
		end #unless
		aCsvRow[:payment] = payment
	} #each
	return aCsv
end #def

# 「クーポン」に何か入力されていれば、クーポン利用とみなす
def coupon(aCsv)
	aCsv.each {|aCsvRow|
		couponFlag = true
		if aCsvRow[:クーポン].nil?
			couponFlag = false
		end #if
		aCsvRow[:coupon] = couponFlag
	}
	return aCsv
end #def

# base: 必要な案件データを出力
if ARGV.include?('base')
	allCsv3 = selectCsvColumn3(inputCsv,reqColumns)
	puts coupon(payment(allCsv3)).to_csv
	exit
# 「dataFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/base2.csv'」
end #if


# カラムモードでのカラム(列)、つまり[要素1つの行列]の行列([[a], [b], [c]])を、普通に行列([a,b,c])に展開
def makeColumnAryFlat(aCsv, columnName)
	returnAry = []
	aCsv.by_col.values_at(columnName).each {|aCsvColumn|
		returnAry << aCsvColumn[0]
	}
	return returnAry
end #def

# ガイド一覧
#guideFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/2024-01-05_guide_utf8.csv'
#guideCsv = CSV.read(guideFile, headers: true)
# ガイド氏名の配列 重複あるので、uniq
#print makeColumnAryFlat(guideCsv, '案内人氏名').uniq.join("\n").chomp
#exit

content = <<EOS
阿部　一男
五十嵐　和一
池田　克彦
伊藤　良孝
大江　進
大野木　佳代子
小松　和彦
小松　礼子
今野　幸男
佐々木　堅士
佐々木　昌喜
須田　祐司
髙橋　治
戸田　久一
畠中　裕之
樋口　信義
豊後　富也
森　寛
渡部　進
石垣　達也
伊藤　留美子
齊藤　淨
佐藤　りつ
茂野　正信
早川　恵
松本　恭博
渡邉　均
石澤　宏基
奥山　和子
柴田　香菜子
菅原　重明
林　晶
守屋　裕孝
横山　博
今井　貴恵
大滝　宗徳
小松　剛
齋藤　美由紀
繁田　久美子
相馬　元明
三浦　将人
佐藤　正俊
佐藤　幸也
相馬　孝一
羽山　みち子
森　康彰
池田　朱美
遠田　眞澄
佐々木　盾
土岐田　勇
三浦　成子
梶原　有希子
太田　良行
保科　恵一
一関　敦子
加川　正夫
齋藤　智也
石橋　英一
菊地　美栄子
小嶋　真紀子
小嶋　裕
佐々木　英樹
澁谷　智子
堀　律子
正木　博美
三浦　敦子
阿部　清生
伊東　温子
伊藤　良明
工藤　純
佐藤　眞由子
鈴木　義明
須田　正雄
須藤　健一
髙岸　康雄
松本　小三郎
佐藤　クリストファ
山科　みどり
新井　真知子
EOS

# 石𣘺　英一
#guideNameAry = content.chomp.gsub(/𣘺/, '橋').split(/\R/)
guideNameAry = content.chomp.split(/\R/)

# aCsvRowの中の、columnsAryの項目の配列を取得
def pickupColumns(aCsvRow, columnsAry)
	return columnsAry.map {|item| aCsvRow[item.to_sym]}
end #def

$guideNameColumn = ['案内人1', '案内人2', '案内人3', '案内人4', '案内人5', '案内人6', '案内人7', '案内人8']
$guideTimeColumn = ['ガイド時間11', 'ガイド時間22', 'ガイド時間33', 'ガイド時間44', 'ガイド時間55', 'ガイド時間66', 'ガイド時間77', 'ガイド時間88']
# ガイド料金11〜88、ガイド料金「総計」
$guideFeeColumn = ['ガイド料金11', 'ガイド料金22', 'ガイド料金33', 'ガイド料金44', 'ガイド料金55', 'ガイド料金66', 'ガイド料金77', 'ガイド料金88']
# ガイド名が入ってないところは、(ガイド時間、)ガイド料金入ってないことを確かめる
def feeCheck(aCsv)
	guideNameColumn = $guideNameColumn
	guideTimeColumn = $guideTimeColumn
# ガイド料金11〜88、ガイド料金「総計」
	guideFeeColumn = $guideFeeColumn
	
	aCsv.each_with_index {|aCsvRow, idx|
# ガイド氏名、ガイド料金
		guideNameFeeArys = [guideNameColumn, guideFeeColumn].map {|item| pickupColumns(aCsvRow, item)}
# ガイド時間
		guideTimeAry = guideTimeColumn.map {|item| aCsvRow[item]}
		guideNameAry = guideNameFeeArys[0]
		guideFeeAry = guideNameFeeArys[1]
# ガイド氏名が入ってないところは？
		nameNilAry = []
		guideNameAry.each_with_index {|item, idx|
			if item.nil?
				nameNilAry << idx
			end #if
		}
# そこの「ガイド時間」は nil か「0時00分00秒」
#	nameNilTimeAry = nameNilAry.map {|item| guideTimeAry[item]}
#print idx.to_s + ': '
#pp nameNilTimeAry
#	nameNilTimeAry.each {|item|
#		if !item.nil? && item != '0時00分00秒'
#			puts "#{idx}: time is no nil"
#			pp nameNilTimeAry
#		end #if
#	}
# そこの「ガイド料金」は nil か「0時00分00秒」
		nameNilFeeAry = nameNilAry.map {|item| guideFeeAry[item]}
#print idx.to_s + ': '
#pp nameNilFee2Ary
		nameNilFeeAry.each {|item|
			if item != '0' && !item.nil?
				puts "#{idx}: fee is no 0"
				pp nameNilFeeAry
			end #if
		}
	}
end #def

#feeCheck(dataCsv)
#exit

# ガイド氏名の正規化
# 「五十嵐　和 一」->「五十嵐　和一」
# 「[0-9]+ 〜〜」->「〜〜」
# 「石.　英一」->「石橋　英一」
def normalizedName(aName)
	return aName
#	return aName.gsub(/ /, '').gsub(/[0-9]/, '')
#.gsub(/石.　英一/, '石橋　英一')
end #def

# ガイド氏名(正規化後)、あらかじめ取得しておいたガイド一覧の中にあるか
def guideNameCheck(aCsv, nameAry)
	aCsv.each_with_index {|aCsvRow, idx|
# ガイド氏名
		guideNameAry = $guideNameColumn.map {|item| aCsvRow[item]}
		guideNameAry.compact!
#		pp guideNameAry
		guideNameAry.each {|item|
			unless nameAry.include?(normalizedName(item))
				puts " ^ ^ 「#{item}」 ^ ^"
			end #unless
		}
	}
end #def

#pp guideNameAry
#guideNameCheck(dataCsv, guideNameAry)
#exit

# 個数チェック
def guidesHashCountCheck(aCsv)
	count = 0
	aCsv.each_with_index {|aCsvRow, idx|
		guidesNameAry = pickupColumns(aCsvRow, $guideNameColumn)
		guidesTimeAry = pickupColumns(aCsvRow, $guideTimeColumn)
		guidesFeeAry = pickupColumns(aCsvRow, $guideFeeColumn)
		unless guidesNameAry.count == guidesTimeAry.count && guidesTimeAry.count == guidesFeeAry.count
			puts "\n\n"
			puts "#{idx}: count_error"
			pp guidesNameAry
			pp guidesTimeAry
			pp guidesFeeAry
			puts "\n\n"
		else
			count += 1
		end #unless
		puts "#{count} row is OK."
	}
end #def

# 従事時間の表示フォーマット
def timeRangeFormat(hmsAry)
	mFormat = sprintf("%02d", hmsAry[1])
	return "#{hmsAry[0]}:#{mFormat}"
end #def

# 案件の、ガイド名・時間・料金の各配列、ガイドごと{氏名, 時間, 料金}のハッシュの配列で返す
def getGuidesHash(namesAry, timesAry, feesAry)
	guidesHashAry = []
	namesAry.each_with_index {|aName, idx|
# ガイド名入ってるところを…
		unless aName.nil?
			guideTimeHMSAry = /([0-9]+)時([0-9]+)分([0-9]+)秒/.match(timesAry[idx]).to_a.values_at(1,2,3).map{|item| item.to_i}
			guideFee = feesAry[idx].to_i
			guidesHashAry << {:name => aName, :time => timeRangeFormat(guideTimeHMSAry), :fee => guideFee}
		end #unless
	}
	return guidesHashAry
end #def

# ガイド料、支払い方法、クーポン から、振込額/納付手数料を計算
def guideCharge(fee, payment, coupon, cancel)
	charge = nil
	unless fee.nil?
		if cancel == '▲' # 当日キャンセルは半額振込、手数料 10% 差し引く
			charge = fee*(0.45)
		else # 催行
			if payment == :口座 # 手数料 10% 差し引く
				charge = fee*(0.9)
			elsif payment == :現金 # 手数料 10% 徴収
				if coupon.nil?
					charge = fee*(-0.1)
				elsif !coupon
					charge = fee*(-0.1)
				elsif coupon
					charge = fee*(-0.2)
#				elsif coupon.downcase == 'true' # Numbers で編集・書き出したもの(couponが大文字)に対処
#					charge = fee*(-0.2)
				end #if coupon
			end #if payment
		end #if cancel
	end #unless
	return charge.to_i || nil
end #def

# 年月日の表示フォーマット
def dateFormat(ymdAry)
#	mFormat = sprintf("%02d", hmsAry[1])
	return "#{ymdAry[0]}/#{ymdAry[1]}/#{ymdAry[2]}"
end #def

# 各案件、ガイド(氏名、時間、料金)取得
def getGuides(aCsv)
	table = CSV::Table.new([], headers: [:name, :time, :fee, :tourID, :date, :payment, :coupon, :charge])
	aCsv.each_with_index {|aCsvRow, idx|
		guidesNameAry = pickupColumns(aCsvRow, $guideNameColumn)
		guidesTimeAry = pickupColumns(aCsvRow, $guideTimeColumn)
		guidesFeeAry = pickupColumns(aCsvRow, $guideFeeColumn)

		getGuidesHash(guidesNameAry, guidesTimeAry, guidesFeeAry).each {|item|
			aCharge = guideCharge(item[:fee], aCsvRow[:payment], aCsvRow[:coupon], aCsvRow[:キャンセル])
			dateAry = /([0-9]{4})年([0-9]{2})月([0-9]{2})日/.match(aCsvRow[:ガイド実施日2]).to_a.values_at(1,2,3).map{|item| item.to_i}
			rowValues = item.values + [aCsvRow[:管理番号], dateFormat(dateAry), aCsvRow[:payment], aCsvRow[:coupon], aCharge]
			table << CSV::Row.new(table.headers, rowValues)
		}

	}
	return table
end #def


allCsv3 = selectCsvColumn3(inputCsv,reqColumns)
dataCsv = coupon(payment(allCsv3))

#dataFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/base1.csv'
#dataCsv = CSV.read(dataFile, headers: true)

# guid_teste: 入力されているガイド人数と従事時間、金額の人数が同じか
if ARGV.include?('guide_check')
	guidesHashCountCheck(dataCsv).to_csv
end #if

# guide: 各案件での、ガイドごとのの支払い金額
if ARGV.include?('guide')
	puts getGuides(dataCsv).to_csv
end #if

=begin

=end