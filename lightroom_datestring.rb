#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

inputString = ARGV.shift.delete("^0-9")
inputStringAry = inputString.chars
puts '20' + inputStringAry[0].to_s + inputStringAry[1].to_s + '-' + inputStringAry[2].to_s + inputStringAry[3].to_s + '-' + inputStringAry[4].to_s + inputStringAry[5].to_s
