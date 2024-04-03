#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

	require 'csv'
	require 'pp'

inputCSV = CSV.read(ARGV.shift)

inputCSV.each { |row|
	hour = ''
	row.each { |item|
		if /（([0-9])h）/=~ item
			hour = $1
			break
		end
	}
	puts hour
}
#pp inputCSV
