# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = 'UTF-8'
require 'date'
require 'roo'
require 'telephone_number'

inputFile = ARGV.shift

xlsx = Roo::Spreadsheet.open(inputFile)
#puts xlsx.info
thisSheet = xlsx.sheet(0)
rtnHash = {:name => thisSheet.c5}
rtnHash[:address] = thisSheet.c6.tr('Ａ-Ｚａ-ｚ０-９－', 'A-Za-z0-9\-')
rtnHash[:tel1] = TelephoneNumber.parse(thisSheet.c8, :jp).national_number
rtnHash[:fax] = TelephoneNumber.parse(thisSheet.c9, :jp).national_number
rtnHash[:mail] = thisSheet.c10
rtnHash[:tel2] = TelephoneNumber.parse(thisSheet.c11, :jp).national_number
rtnHash[:date] = Date.parse(thisSheet.c12)

timeAry = thisSheet.c13.split(' ～ ')
startTime = Time.parse("#{rtnHash[:date]} #{timeAry[0]}:00")
endTime = Time.parse("#{rtnHash[:date]} #{timeAry[1]}:00")
timePeriod = endTime - startTime
# 30分(1800秒)単位で切り上げ、時間単位に
calTime = ((timePeriod/1800).ceil.to_f)/2
rtnHash[:time] = thisSheet.c14
rtnHash[:calTime] = calTime
rtnHash[:fee] = calTime*2000.to_i
rtnHash[:person] = thisSheet.c15.to_i
rtnHash[:guide]  = (rtnHash[:person].to_f/10).ceil.to_i
rtnHash[:age] = thisSheet.c16
rtnHash[:comm_pers] = thisSheet.c17
rtnHash[:distin] = thisSheet.c18
rtnHash[:gather] = thisSheet.c19
rtnHash[:diss] = thisSheet.c20
rtnHash[:event] = thisSheet.c21
rtnHash[:comm_dist] = thisSheet.c22
rtnHash[:transport] = thisSheet.c23
rtnHash[:comm_t] = thisSheet.c24
rtnHash[:rain] = thisSheet.c25
rtnHash[:pay] = thisSheet.c26
rtnHash[:other] = thisSheet.c27
pp rtnHash

wdayAry = ['日', '月', '火', '水', '木', '金', '土']

def add_separaor(str, separator = ",")
	return str.to_s.reverse.scan(/.{1,3}/).join(separator.to_s).reverse
end


mailContent = <<EOS
chokai-tobishima_yuza_nintei@googlegroups.com

#{rtnHash[:date].month}/#{rtnHash[:date].day}(#{wdayAry[rtnHash[:date].wday]}) #{rtnHash[:distin]} (#{rtnHash[:name]}) ガイド募集


遊佐エリア認定ガイドの皆々さま

畠中です。

#{rtnHash[:name]}さまからガイド依頼ありました。

日時　　：　#{rtnHash[:date].month}月#{rtnHash[:date].day}日(#{wdayAry[rtnHash[:date].wday]}) #{startTime.strftime("%-H:%M")} ～ #{endTime.strftime("%-H:%M")} (#{rtnHash[:time]}時間)
行先　　：　#{rtnHash[:distin]}
集合・解散：#{rtnHash[:gather]}、#{rtnHash[:diss]}
参加人数：　#{rtnHash[:person]}名
募集人数：　#{rtnHash[:guide]}名
ガイド料：　#{add_separaor(rtnHash[:fee].to_i)}円/人

募集締切：　%月%日(%)

ガイド担当希望の方、メールでご返信お願いいたします。



2025(令和7年)　

#{rtnHash[:date].month}/#{rtnHash[:date].day}(#{wdayAry[rtnHash[:date].wday]}) #{rtnHash[:distin]} (#{rtnHash[:name]}) 担当ガイド決定のお知らせ


下記の件、%%さんに決定いたしました。

日時　　：　#{rtnHash[:date].month}月#{rtnHash[:date].day}日(#{wdayAry[rtnHash[:date].wday]}) #{startTime.strftime("%-H:%M")} ～ #{endTime.strftime("%-H:%M")} (#{rtnHash[:time]}時間)
行先　　：　#{rtnHash[:distin]}
参加人数：　#{rtnHash[:person]}名
募集人数：　#{rtnHash[:guide]}名


EOS

puts mailContent