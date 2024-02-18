#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_fee.rb test/base/guide
# test: 
# base: 案件を出力
# guide_check: ガイド人数・従事時間・ガイド料の各項目数が同じか
# guide_fee_csv: ガイドごとの支払い金額明細をCSV出力
# ガイド受付システムからExportしたCSVファイルから、ガイドごとの支払い金額集計

require 'csv'
require 'pp'
require 'thinreports'

inputFile = ARGV.shift
inputFileContents = IO.read(inputFile, encoding: 'SJIS').encode('UTF-8')

header_converter = lambda {|h| h.to_sym}
inputCsv = CSV.parse(inputFileContents, headers: true, skip_blanks: true, header_converters: header_converter)

## -- チェック用 --
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
	exit
end #if

reqColumns = ['申込番号', '管理番号', 'エリア', 'エリア名', '団体名', '氏名', 'ガイド実施日', '開始時刻', '終了時刻', '開始時刻2', '終了時刻2', 'モデルコース', '催し等', 'モデルコース2', '支払い方法', '案内人1', '案内人2', '案内人3', '案内人4', '案内人5', '案内人6', '案内人7', '案内人8', 'ガイド完了', 'ガイド時間', 'ガイド時間1', 'ガイド時間2', 'ガイド時間3', 'ガイド時間4', 'ガイド時間5', 'ガイド時間6', 'ガイド時間7', 'ガイド時間8', 'ガイド時間11', 'ガイド時間22', 'ガイド時間33', 'ガイド時間44', 'ガイド時間55', 'ガイド時間66', 'ガイド時間77', 'ガイド時間88', 'ガイド料金', 'ガイド料金2', 'ガイド料金3', 'ガイド料金4', 'ガイド料金5', 'ガイド料金6', 'ガイド料金7', 'ガイド料金8', 'ガイド料金合計', 'キャンセル', 'キャンセル2', '支払い', 'クーポン', 'ガイド料金11', 'ガイド料金22', 'ガイド料金33', 'ガイド料金44', 'ガイド料金55', 'ガイド料金66', 'ガイド料金77', 'ガイド料金88', 'ガイド料金総計', 'ガイド実施日2']

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

# base: 案件を出力 → 保存
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

# aCsvRowの中の、columnsAryの項目の配列を取得
def pickupColumns(aCsvRow, columnsAry)
	return columnsAry.map {|item| aCsvRow[item.to_sym]}
end #def

$guideNameColumn = ['案内人1', '案内人2', '案内人3', '案内人4', '案内人5', '案内人6', '案内人7', '案内人8']
$guideTimeColumn = ['ガイド時間11', 'ガイド時間22', 'ガイド時間33', 'ガイド時間44', 'ガイド時間55', 'ガイド時間66', 'ガイド時間77', 'ガイド時間88']
# ガイド料金11〜88、ガイド料金「総計」
$guideFeeColumn = ['ガイド料金11', 'ガイド料金22', 'ガイド料金33', 'ガイド料金44', 'ガイド料金55', 'ガイド料金66', 'ガイド料金77', 'ガイド料金88']

## -- チェック用 --
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

# ガイド氏名、あらかじめ取得しておいたガイド一覧の中にあるか
def guideNameCheck(aCsv, nameAry)
	aCsv.each_with_index {|aCsvRow, idx|
# ガイド氏名
		guideNameAry = $guideNameColumn.map {|item| aCsvRow[item]}
		guideNameAry.compact!
#		pp guideNameAry
		guideNameAry.each {|item|
			unless nameAry.include?(item)
				puts " ^ ^ 「#{item}」 ^ ^"
			end #unless
		}
	}
end #def

#guideNameCheck(dataCsv, guideNameAry)
#exit

# guide_check: 入力されているガイド人数と従事時間、金額の人数が同じか
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
				if coupon.nil? || !coupon
					charge = fee*(-0.1)
				elsif coupon == true
					charge = fee*(-0.2)
				elsif coupon.downcase == 'true' # Numbers で編集・書き出したもの(couponが大文字)に対処
					charge = fee*(-0.2)
				elsif coupon.downcase == 'false' # Numbers で編集・書き出したもの(couponが大文字)に対処
					charge = fee*(-0.1)
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

# 各案件、ガイドごと(氏名、時間、料金)取得
# [:name, :time, :fee, :tourID(管理番号), :date,  :course(モデルコース), :event(催し等), :cancel(キャンセル), :payment, :coupon, :charge]
def getGuides(aCsv)
	headersBaseAry = [:name, :time, :fee]
# 追加分 :tourID(管理番号), :date,  :course(), :event(), :cancel(), :payment, :coupon, :charge
	headersAddAry = [:tourID, :date, :course, :event, :cancel, :payment, :coupon, :charge]
	headersAry = headersBaseAry + headersAddAry
	table = CSV::Table.new([], headers: headersAry)
	aCsv.each_with_index {|aCsvRow, idx|
		guidesNameAry = pickupColumns(aCsvRow, $guideNameColumn)
		guidesTimeAry = pickupColumns(aCsvRow, $guideTimeColumn)
		guidesFeeAry = pickupColumns(aCsvRow, $guideFeeColumn)
# 各ガイドごとのHash
		getGuidesHash(guidesNameAry, guidesTimeAry, guidesFeeAry).each {|item|
# 年月日それぞれ抽出
			dateAry = /([0-9]{4})年([0-9]{2})月([0-9]{2})日/.match(aCsvRow[:ガイド実施日2]).to_a.values_at(1,2,3).map{|item| item.to_i}
# 支払い(請求)額計算。口座/現金、クーポン、当日キャンセルから。
			aCharge = guideCharge(item[:fee], aCsvRow[:payment], aCsvRow[:coupon], aCsvRow[:キャンセル])
# 案件のデータから、必要な項目持ってきて付加。headersAddAry に合わせる
			rowValues = item.values + [aCsvRow[:管理番号], dateFormat(dateAry), aCsvRow[:モデルコース], aCsvRow[:催し等], aCsvRow[:キャンセル], aCsvRow[:payment], aCsvRow[:coupon], aCharge]
			table << CSV::Row.new(table.headers, rowValues)
		}

	}
	return table
end #def

# guide_fee: getGuidesで返ったガイド・案件ごとのtable、ガイドごとにまとめ実施日で連番付加しHashで返す
# {ガイド1 => [案件CSV.Row_1,案件CSV.Row_2,案件CSV.Row_3, ...], ガイド2 => ...}
# 案件CSV.Row: 
def addNumInThisGuide(aTable)
	guideHash = {}
# 各ガイドごと、従事した案件のArrayをHashに。
	aTable.each {|aRow|
		if guideHash[aRow[:name]].nil?
			guideHash[aRow[:name]] = [aRow]
		else
			guideHash[aRow[:name]] << aRow
		end #if
	}
	guideHash.each {|guideName, guideAry|
		count = 1
# 日付でソート
		guideAry.sort! {|a,b|
			Date.parse(a[:date]) <=> Date.parse(b[:date])
		}
# 連番付加
		guideAry.each {|item|
			item[:num_in_this_guide] = count
			count += 1
		}
	}
	return guideHash
end #def

# addNumInThisGuideで作ったガイドごとのHashから、PDF作る。ガイドの所属を、guideListCsvから取得
# 'GuidePDF'フォルダの中の、エリアNo.(1..4)の中にPDF作る
def toPdfGuideHash(guideHash, guideListCsv, pdfTemplate)
	aTour = guideHash[guideHash.keys[0]][0]
	thisGuide = guideListCsv.select {|aGuide|
		aGuide[:name] == guideHash.keys[0]
	}
	guideHash[guideHash.keys[0]].each {|aTour|
		
	}
	guideAreaHash = {'1' => 'にかほエリア',  '2' => '由利本荘エリア',  '3' => '遊佐エリア',  '4' => '酒田・飛島エリア'}
	paramsHash2 = {}
	paramsHash2[:type] = :section
	paramsHash2[:layout_file] = pdfTemplate
	paramsHash3 = {}
	contentsHash = {}
	contentsHash[:headers] = {name_total: {}}
	contentsHash[:headers][:name_total][:items] = {area: guideAreaHash[thisGuide[0][:reg_area]]}
	contentsHash[:headers][:name_total][:items][:name] = guideHash.keys[0],
	contentsHash[:details] = []
	#guideHash[guideHash.keys[0]].each {|guide, tourAry|
	totalValue = 0
	guideHash[guideHash.keys[0]].each {|aTour|
		aTourHash = {id: 'tours', items: {}}
		aTourHash[:items][:index] = aTour[:num_in_this_guide]
		aTourHash[:items][:date] = aTour[:date]
		aTourHash[:items][:course] = aTour[:course]
		aTourHash[:items][:event] = aTour[:event]
		aTourHash[:items][:fee] = aTour[:fee]
		aTourHash[:items][:cancel] = aTour[:cancel]
		aTourHash[:items][:payment] = aTour[:payment]
		aTourHash[:items][:charge] = aTour[:charge]
		contentsHash[:details] << aTourHash
		totalValue += aTour[:charge].to_i
	}
	contentsHash[:headers][:name_total][:items][:total] = totalValue
	groupsAry = [contentsHash]
	paramsHash3[:groups] = groupsAry
	paramsHash2[:params] = paramsHash3
	Thinreports.generate(paramsHash2, filename: "GuidePDF/#{thisGuide[0][:reg_area]}/#{guideHash.keys[0]}.pdf")
#	pp paramsHash2
#	pp paramsHash
# ガイド料.tlf
=begin
paramsHash = {
	type: :section,
	layout_file: pdfTemplate,
# paramsHash3
	params: {
# groupsAry
		groups: [
# contentsHash
			{
				headers: {
					name_total: {
						items: {
							area: guideAreaHash[thisGuide[0][:reg_area]],
							name: guideHash.keys[0],
							total: 'test'
						}
					}
				},
				details: [
					{
						id: 'tours',
						items: {
							index: aTour[:num_in_this_guide],
							date: aTour[:date],
							course: aTour[:course],
							event: aTour[:event],
							fee: aTour[:fee],
							cancel: aTour[:cancel],
							payment: aTour[:payment],
							charge: aTour[:charge]
						}
					}
				]
			}
		]
	}
}
=end
end #def


# addNumInThisGuideで作ったガイドごとのHashから、csv作る
def toCsvGuideHash(guideHash)
# 最初のガイドの最初の案件取り出し、headers 取得
	firstRow = guideHash[guideHash.keys[0]][0]
	addHeaders = firstRow.headers
# 出力CSV
	table = CSV::Table.new([], headers: addHeaders)
	guideHash.each {|name, tourAry|
		tourAry.each {|aTour|
			table << aTour
		}
	}
	return table
end #def

# 開始日、最終日を設定、その範囲のものだけ取り出す
def byDateRange(aCsv, index:, from: nil, to: nil)
	if !to.nil?
		aCsv.delete_if {|aRow|
			Date.parse(aRow[index.to_sym]) > Date.parse(to)
		}
	end #if
	if !from.nil?
		aCsv.delete_if {|aRow|
			Date.parse(aRow[:date]) < Date.parse(from)
		}
	end #unless
	return aCsv
end #def

allCsv3 = selectCsvColumn3(inputCsv,reqColumns)
dataCsv = coupon(payment(allCsv3))

#dataFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/base1.csv'
#dataCsv = CSV.read(dataFile, headers: true)

# guide_check: 入力されているガイド人数と従事時間、金額の人数が同じか
if ARGV.include?('guide_check')
	guidesHashCountCheck(dataCsv).to_csv
end #if

fromDate = '2023/02/01'
toDate = '2024/01/31'


feePdfTemplate = 'ガイド料.tlf'
# guide_fee_pdf: ガイドごとの支払い金額明細をPDF出力
if ARGV.include?('guide_fee_pdf')
	guideListFile = 'guideName.csv'
	allGuideListCsv = CSV.read(guideListFile, headers: true, skip_blanks: true, header_converters: header_converter)
#pp allGuideListCsv
	toPdfGuideHash(addNumInThisGuide(getGuides(dataCsv)), allGuideListCsv, feePdfTemplate)
end #if

# guide_fee_csv: ガイドごとの支払い金額明細をベタでCSV出力
if ARGV.include?('guide_fee_csv')
	puts toCsvGuideHash(addNumInThisGuide(getGuides(dataCsv)))
#	puts addNumInThisGuide(getGuides(byDateRange(dataCsv, index: 'ガイド実施日', to: toDate))).to_csv
#	puts addNumInThisGuide(byDateRange(getGuides(dataCsv), index: 'date', to: toDate)).to_csv
end #if

=begin

=end