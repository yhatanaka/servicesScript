#!/usr/bin/ruby
# -*- coding: utf-8 -*-
Encoding.default_external = "UTF-8"

newLineAry = []
i = 0
ARGV.each do |f|
	f.dup.force_encoding("UTF-8").split("\n").each do |line|
		i = i+1
		newLineAry << i.to_s + line
	end #f.each
end #ARGV.each
puts newLineAry.join("\n")