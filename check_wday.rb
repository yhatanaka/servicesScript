#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'Date'
require 'pp'

# 「年」の指定がなく、しかも年末が近い場合、何ヶ月先までを「来年」の日付と判断するか
# 3だと、10/1には「1/1」(3ヶ月後)は次年、「1/2」(+1日後)は今年の日付と解釈
MonthThrsld = 4
# day_str_0 = '2021/11/3'
day_str_0 = ARGV.shift
day_str_1 = +day_str_0
day_str = day_str_1.force_encoding('UTF-8').gsub(/[ 　]/, '')


def split_date(str)
	splitted_date = /((?<y>[0-9]+)年)?[ ]?(?<m>[0-9]+)月[ ]?(?<d>[0-9]+)日.*/.match(str)
# (〜年)〜月〜日
	unless splitted_date.nil?
		return {'y' => splitted_date[:y], 'm' => splitted_date[:m], 'd' => splitted_date[:d]}
# (〜/)〜/〜
	else
		splitted_date_ary = str.split('/')
		return {'y' => splitted_date_ary[-3], 'm' => splitted_date_ary[-2], 'd' => splitted_date_ary[-1]}
	end #if
end #def

# 「年」の指定がない場合、今年かあるいは明けて来年か
def guess_year(date_hash)
# 「年」の指定がない場合
	if date_hash['y'].nil?
		thisYear = Date.today.year
		date_hash['y'] = Date.today.year
# 今年だったらこの日になる
		thisYearsDate = Date.parse(format_ymd(date_hash))
# 対象日がMonthThrsld月後まででしかも来年、逆に言えば今年だとした場合の日付が(12-MonthThrsld)ヶ月以前の場合、来年とする
		if thisYearsDate <= Date.today.prev_month(12-MonthThrsld)
			date_hash['y'] = date_hash['y'] + 1
		end #if
	end #if
	return date_hash
end #def

# Date.parse 用に、y/m/d という文字列を返す
def format_ymd(date_hash)
	return date_hash['y'].to_s + '/' + date_hash['m'].to_s + '/' + date_hash['d'].to_s
end #def

# 
def parse_date(str)
	return Date.parse(format_ymd(guess_year(split_date(str))))
end #def


wday_str = ['日','月','火','水','木','金','土']

print wday_str[parse_date(day_str).wday]
# pp split_date(day_str)



#begin
#	check_date = Date.parse(day_str)
#print wday_str[check_date.wday]
#rescue => e
#	p /((?<y>[0-9]+)年)?(?<m>[0-9]+)月(?<d>[0-9]+)日/.match(day_str)
#end

