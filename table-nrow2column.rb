#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby table-nrow2column.rb input.txt column_num
# n行ごとにタブで繋げて1行に
require 'pp'

inputFile = ARGV.shift
input_txt = File.read(inputFile)
input_ary = input_txt.split("\n")

column_num = ARGV.shift.to_i

output_ary = []
output_row = []
input_ary.each_with_index {|itm, idx|
	output_row << itm
	if (idx+1)%column_num == 0
		output_ary <<  output_row
		output_row = []
	end #if
}

output_txt = ""
output_ary.each {|aRow|
	output_txt << aRow.join("\t") + "\n"
}
puts output_txt