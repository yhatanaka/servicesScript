# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'pp'
require 'Date'
require 'Oga'
periodArray = []
dateArray = []

ARGV.each do |f|
# yyyy-m-n
	periodArray = f.split('-')
end

# periodArray = '2021-12-2'.split('-')

targetYear = periodArray[0].to_i
targetMonth = periodArray[1].to_i
if periodArray[2].to_i == 1 then
	startDate = 1
	lastDate = 15
elsif periodArray[2].to_i == 2 then
	startDate = 16
	lastDate = Date.new(targetYear, targetMonth, 1).next_month.prev_day.day
end #if

i = 0
while i < 7
	theDate = Date.new(targetYear, targetMonth, startDate + i)
	if theDate.wday == 0 || theDate.wday == 5 then
		dateArray << startDate + i
	end #if
	i += 1
end #while

if dateArray.size == 2
	Array.new(dateArray).each do |theDate|
		for i in [1,2]
			if theDate + i*7 <= lastDate then
				dateArray << theDate + i*7
			end #if
		end #for
	end #each
end #if

handle = File.open('/Users/hatanaka/Documents/url.html')
document = Oga.parse_html(handle)
body = document.at_xpath('html/body')

pageFormatString = <<~EOS
	https://ja.wikipedia.org/wiki/%d月%d日
	https://netlab.click/todayis/%02d%02d
	https://www.nnh.to/%02d/%02d.html
	https://www.php.co.jp/fun/today/%02d-%02d.php
	https://kyou-nannohi.com/day-%02d%02d/
	https://sonohino.com/%02d%02d-2
EOS
pageFormatAry = pageFormatString.split(/\n/)
pageFormatString4enwikipedia = 'https://en.wikipedia.org/wiki/%s_%d'

dateArray.sort.each do |aDate|
	searchMonth = targetMonth
	searchDay = aDate
	puts searchDay

	urlList = []
	pageFormatAry.each do |page|
		urlList.push(sprintf(page, searchMonth, searchDay))
	end #each
	monthName = Date.new(targetYear,searchMonth,1).strftime(format = '%B')
	pp monthName
	urlList.push(sprintf(pageFormatString4enwikipedia, monthName, searchDay))
	#pp urlList
	
	ul = Oga::XML::Element.new(:name => 'ul')
	
	urlList.each do |page|
		a_href = Oga::XML::Element.new(:name => 'a')
		a_href.inner_text = page
		a_href.set('href', page)
		a_href.set('target', '_blank')
		li = Oga::XML::Element.new(:name => 'li')
		li.children << a_href
		ul.children << li
	end #each
	
	body.children << ul

end #each

puts document.to_xml
