# -*- coding: utf-8 -*-
require 'pp'
require 'Date'

# 毎月1〜7日の金曜日 or 日曜日が1回目OA日
# 提出はOA 3 or4日前

# 3日後から始めて1週間（10日後まで）
todaysDate = Date.today
# 3日後以降，3週間分（3〜23）
nextOnAirDay = (3..10).each do |i|
	searchedDay = todaysDate + i
	if (searchedDay.wday == 0 || searchedDay.wday == 5) then
		break searchedDay
	end #if
end #each

episodeYear = nextOnAirDay.year
episodeMonth = nextOnAirDay.month

if episodeMonth == 12 then
	nextMonth = 1
	nextYear = episodeYear + 1
else
	nextMonth = episodeMonth + 1
	nextYear = episodeYear
end #if

print "#{episodeYear}-#{episodeMonth}=#{episodeYear}-#{episodeMonth}&#{nextYear}-#{nextMonth}=#{nextYear}-#{nextMonth}"
