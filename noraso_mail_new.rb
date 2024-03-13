#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'
require 'Date'

todaysDate = Date.today
if todaysDate.day > 3
# 3日後以降，1週間分（3〜10）
	nextMonth = Date.new(todaysDate.year, todaysDate.month+1, 1)
	episodeYear = nextMonth.year
	episodeMonth = nextMonth.month
else
	episodeYear = todaysDate.year
	episodeMonth = todaysDate.month
end

mailTitle = "ノラーソ・ビヤ・マールキ #{episodeYear}年#{episodeMonth}月"

mailBodyOrig = <<EOS
水落さま

お世話になっております、畠中です。
ノラーソ・ビヤ・マールキ　#{episodeYear}年#{episodeMonth}月分です。
よろしくお願いいたします。
EOS

answer = "body=#{mailBodyOrig}&subject=#{mailTitle}"
print answer