#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby zengin.rb input.csv output.txt (test: 月日「0101」/ chk: 使用不能文字チェック / view: 書き出さずに表示)
require 'csv'
require 'nkf'
require 'date'

inputFile = ARGV.shift
outputFile = ARGV.shift
testFlag = ARGV.shift

if inputFile.nil?
	puts 'usage: ruby zengin.rb input.csv output.txt (test: 月日「0101」/ chk: 使用不能文字チェック / view: 書き出さずに表示)'
	exit
end #if

shitenCode = {'016' => 'ﾕｻﾞ', '002' => 'ｻｶﾀﾁﾕｳｵｳ', '021' => 'ﾌｸﾗ', '16' => 'ﾕｻﾞ', '2' => 'ｻｶﾀﾁﾕｳｵｳ', '21' => 'ﾌｸﾗ'}
# 2022-03-01以降、吹浦支店(021)は遊佐支店(016)へ
dateFukura2Yuza = Date.new(2022,3,1)

# ymd が土日なら次の月曜返す
def payDate(y,m,d)
	iDate = Date.parse("#{y}-#{m}-#{d}")
# 土曜
	if iDate.wday == 6
		payDate = iDate.next_day(2)
# 日曜
	elsif iDate.wday == 0
		payDate = iDate.next_day(1)
	else
		payDate = iDate
	end #if

	return payDate
end #def

# -w: 入力 UTF-8, -Z1: 全角スペースをasciiスペースに, -Z4: 全角カタカナを半角カタカナに, -w: 半角カタカナを全角に変換せず出力
def convZengin(str)
	noKomojiStr = str.gsub(/[ャュョェ?？]/, {'ャ' => 'ヤ', 'ュ' => 'ユ', 'ョ' => 'ヨ', 'ェ' => 'エ', '?' => '', '？' => ''})
	return NKF.nkf('-w -Z1 -Z4 -x', noKomojiStr)
end

# 前後のスペースなど削除、「,」削除、整数型に
def convPayValue2int(str)
	return str.strip.gsub(',', '').to_i
end #def

# 店舗名で使用できる文字
# - カナ(ヲと小文字を除く。ただし、振込入金通知、入出金取引明細、総合振込、振込口座照会(依頼明細)および振込口 座照会(処理結果明細)の各業務における支店名、仕向店名、仕向支店名 および被仕向支店名については、小文字を除く)
# - 濁点、半濁点、英大文字 (A~Z)、数字(0~9)、記号1種類( -〔ハイフン〕)のみ
def convTenpo(str)
	charNoTenpo = /([^ｱ-ﾜﾝﾞﾟ0-9A-Z\-])/
	return convZengin(str).gsub(charNoTenpo, '-')
end #def

def slc_just(str, jst, count)
	if jst == 'r'
		return str.slice(0,count).rjust(count, '0')
	elsif jst == 'l'
		return str.slice(0,count).ljust(count)
	end #if
end #def

charNoNameEtc = /[^ｱ-ﾜﾝﾞﾟ0-9A-Zｰ\- \(\)\.\r\n]/

# 3月からは'016'
if Date.today >= dateFukura2Yuza
	fukuraCode = '016'
else
	fukuraCode = '021'
end #if

begin

# 1. ヘッダー・レコード
	header_record = '1'                           # データ区分（固定値）
	header_record << '91'                          # 種別コード（固定値）
	header_record << '0'                           # コード区分（固定値）
	header_record << '0000101142'                  # 振込依頼人コード（固定値）
	header_record << slc_just(convZengin('ユ)ハタナカ'), 'l', 40)   # 振込依頼人名
	if testFlag == 'test'
		header_record << '0101' # テスト用
	else
		header_record << payDate(Date.today.year, Date.today.month, 28).strftime("%m%d") # 振込実施日
	end #if
	header_record << '4027'                      # 仕向銀行番号（固定値）
	header_record << slc_just('ｼﾖｳﾅｲﾐﾄﾞﾘﾉｳｷﾖｳ', 'l', 15)              # 仕向銀行名（固定値）
	header_record << fukuraCode             # 仕向支店番号
	header_record << shitenCode[fukuraCode].ljust(15)     # 仕向支店名
	header_record << '1'                           # 預金種目(依頼人)（固定値）
	header_record << slc_just('0660143', 'r', 7)                 # 口座番号(依頼人)
	header_record << ''.ljust(17)                # ダミー
	
# 2. データ・レコード
	personsHash = Hash.new
	payouts = CSV.read(inputFile, headers: true)
	payouts.each { |payout|
# 姓ヨミ, 支店, 口座番号, 氏名（カナ）, 名ヨミ, 金額, 連番, 
# 口座番号 => {支店 => , 氏名（カナ）=>, 金額 => , 連番 =>}
		kingaku = convPayValue2int(payout['金額'])
		if kingaku > 0 && payout['姓ヨミ']
# 口座番号が複数(総合交流促進施設) -> 金額合計
			if personsHash.key?(payout['口座番号'])
				personsHash[payout['口座番号']]['金額'] += kingaku
# 普通の顧客
			else
				personsHash[payout['口座番号']] = Hash.new
# 2022-03-01以降、吹浦支店(021)は遊佐支店(016)へ
				if payout['支店コード'].to_i == 21 && Date.today >= dateFukura2Yuza
					personsHash[payout['口座番号']]['支店コード'] = '016'
				else
					personsHash[payout['口座番号']]['支店コード'] = payout['支店コード']
				end #if
				personsHash[payout['口座番号']]['金額'] = kingaku
				personsHash[payout['口座番号']]['連番'] = payout['連番']
				personsHash[payout['口座番号']]['カナ摘要'] = convTenpo(payout['カナ摘要'])
				personsHash[payout['口座番号']]['口座種類'] = convTenpo(payout['口座種類'])
				if payout['氏名カナ']
					accountName = payout['氏名カナ']          # 顧客名
				elsif payout['姓ヨミ']
					if payout['名ヨミ']
						accountNameZen = payout['姓ヨミ'] + ' ' + payout['名ヨミ']
					elsif
						accountNameZen = payout['姓ヨミ']
					end #if
					accountName = convZengin(accountNameZen)          # 顧客名
				end #if
				personsHash[payout['口座番号']]['氏名'] = accountName
			end #if
		end #if
	}

# 	総合交流施設(株) 0591647
	unless personsHash['0591647'].nil?
		personsHash['0591647']['カナ摘要'] = convTenpo('シンブンダイ')
	end #unless

	data_records = ''
	sum_payouts = 0
	personsHash.each {|accountNo, accountHash|
		data_record = '2'                                      # データ区分（固定値）
		data_record << '4027'.rjust(4, '0') # 被仕向銀行番号
		data_record << slc_just('ｼﾖｳﾅｲﾐﾄﾞﾘﾉｳｷﾖｳ', 'l', 15)                           # 被仕向銀行名
		data_record << slc_just(accountHash['支店コード'], 'r', 3) # 被仕向支店番号
		data_record << slc_just(accountHash['カナ摘要'], 'l', 15)                           # 被仕向支店名
		data_record << ''.ljust(4)                            # ダミー
		data_record << slc_just(accountHash['口座種類'], 'r', 1)                                      # 預金種目
		data_record << slc_just(accountNo, 'r', 7)      # 口座番号
		data_record << slc_just(accountHash['氏名'], 'l', 30)          # 顧客名
		data_record << slc_just(accountHash['金額'].to_s, 'r', 10)     # 振込金額(末尾の空白削除、「,」削除)
		data_record << '1'                                      # 新規コード
		data_record << slc_just(accountHash['連番'], 'l', 20)                           # 顧客コード
		data_record << '0'.ljust(1)                            # 振込結果コード
		data_record << ''.ljust(8)                            # ダミー
		if charNoNameEtc.match(data_record).nil?
			data_records << data_record + "\r\n"
			sum_payouts += accountHash['金額']
		else
#pp accountHash
			pp '使用可能文字チェック: ' + accountHash['連番'] + ' ' + accountHash['氏名'] + ': ' + data_record
			pp charNoNameEtc.match(data_record).to_a[0]
		end #if
	}

	# 3. トレーラ・レコード
	trailer_record = '8'                                         # データ区分（固定値）
	trailer_record << slc_just(personsHash.size.to_s, 'r', 6)          # 合計件数
	trailer_record << slc_just(sum_payouts.to_s, 'r', 12) # 合計金額
	trailer_record << '0'.ljust(6)                            # 振込済件数
	trailer_record << '0'.ljust(12)                            # 振込済金額
	trailer_record << '0'.ljust(6)                            # 振込処理不能件数
	trailer_record << '0'.ljust(12)                            # 振込不能金額
	trailer_record <<  ''.ljust(65)                             # ダミー

	# 4. エンド・レコード
	end_record = '9'             # データ区分（固定値）
	end_record << ''.ljust(119) # ダミー

	if testFlag == 'chk'
		pp charNoNameEtc.match(header_record)
		pp charNoNameEtc.match(trailer_record)
		pp charNoNameEtc.match(end_record)
	elsif testFlag == 'view'
		pp header_record
		pp data_records
		pp trailer_record
	else
		File.open(outputFile, 'w', encoding: 'Shift_JIS') { |f|
			f.write(header_record + "\r\n" + data_records + trailer_record + "\r\n" + end_record + "\r\n")
		}
	end #if

# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end