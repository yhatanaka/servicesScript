# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'pp'
require 'Date'
require 'Oga'
dateArray = []

ARGV.each do |f|
	f.split(/\n/).each do |line|
		dateArray << line.split('/')
	end #each
end


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


dateArray.each do |aDate|

	searchMonth = aDate[0]
	searchDay = aDate[1]
	puts searchDay

	urlList = []
	pageFormatAry.each do |page|
		urlList.push(sprintf(page, searchMonth, searchDay))
	end #each
	monthName = Date.new(2021,searchMonth.to_i,1).strftime(format = '%B')
	pp monthName
	urlList.push(sprintf(pageFormatString4enwikipedia, monthName, searchDay))
	#pp urlList
	
	ul = Oga::XML::Element.new(:name => 'ul')
	
	urlList.each do |page|
		a_href = Oga::XML::Element.new(:name => 'a')
		a_href.inner_text = page
		a_href.set('href', page)
		li = Oga::XML::Element.new(:name => 'li')
		li.children << a_href
		ul.children << li
	end #each
	
	body.children << ul

end #each

puts document.to_xml
