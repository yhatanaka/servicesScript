#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

inputString = ARGV.shift.delete("^0-9")

inputStringAry = /2019([0-9][0-9])([0-9][0-9])/.match(inputString).captures
puts '2019-' + inputStringAry[0].to_s + '-'  + inputStringAry[1].to_s
