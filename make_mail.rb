#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'
require 'Date'

toAddress = 'mizuochi@sakatafm.com'
episodeNumberString = ['', '前半', '後半']


# 毎月1〜7日の金曜日 or 日曜日が前半の1回目オンエア日，16〜22日の金曜日 or 日曜日が後半の1回目オンエア日
# 提出は月or火曜なので，オンエア日3 or4日前
# 提出日の3日後以降に，(金曜 or 日曜) && ( 日付が ( 1-7 #1) or ( 16-22 #2) )があれば，1) なら前半，2) なら後半

# 3日後から始めて1週間（10日後まで）
todaysDate = Date.today
# 3日後以降，3週間分（3〜23）
nextOnAirDay = (3..23).each do |i|
	searchedDay = todaysDate + i
	if (searchedDay.wday == 0 || searchedDay.wday == 5) then
		if searchedDay.day <= 7 then
			episodeNumber = 1
			break [searchedDay, episodeNumber]
		elsif searchedDay.day > 15 && searchedDay.day <= 22
			episodeNumber = 2
			break [searchedDay, episodeNumber]
		end #if
	end #if
end #each

episodeYear = nextOnAirDay[0].year
episodeMonth = nextOnAirDay[0].month
episodeNumber = nextOnAirDay[1]

mailTitle = 'ノラーソ・ビヤ・マールキ ' + episodeYear.to_s + '年' + episodeMonth.to_s + '月#' + episodeNumber.to_s

mailBodyOrig = <<EOS
水落さま

お世話になっております、畠中です。
ノラーソ・ビヤ・マールキ　#{episodeYear}年#{episodeMonth}月#{episodeNumberString[episodeNumber]}分です。
よろしくお願いいたします。
EOS

mailBody = mailBodyOrig.gsub(/(\r\n|\r|\n)/){"\n"}
openCommand = 'open mailto:' + toAddress + %Q[\?subject='] + mailTitle + %q['\&body='] + mailBody + %Q[\']
p openCommand
exec openCommand
#?subject=''\&body=hello;"
#p mailTitle
#p mailBodyOrig
