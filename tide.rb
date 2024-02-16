# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'pp'
require 'csv'

resultAry = []
for i in 0..23 do
	resultAry << i
end
resultAry = resultAry + ['年','月','日']
for i in 0..3 do
	resultAry = resultAry + ['満潮時刻','満潮潮位']
end
for i in 0..3 do
	resultAry = resultAry + ['干潮時刻','干潮潮位']
end

resultCSV = CSV::generate_line(resultAry)

fields = 'A3'*24 + 'A2'*3 + 'x2' + 'A4A3'*8
handle = File.open(ARGV.shift).read.split("\n")

handle.each do |line|
	lineAry = []
	line.chomp.unpack(fields).each do |item|
		if item == '9999' || item == '999'
			lineAry << ''
		else
			lineAry << item
		end
	end
	resultCSV << CSV::generate_line(lineAry)
end #each

print resultCSV

=begin 
	if /<a href=[^>]+>([^>]+)</.match(line)
		puts $1
	end #if

=end