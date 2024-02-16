#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

require 'csv'
require 'pp'

inputFile1 = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/base.csv'
inputFileContents1 = IO.read(inputFile1)
inputFile2 = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/base_imported.csv'
inputFileContents2 = IO.read(inputFile2)
inputCsv1 = CSV.parse(inputFileContents1, headers: false)
inputCsv2 = CSV.parse(inputFileContents2, headers: false)

#pp inputCsv2
#puts ' - - - - - - - -'
#puts inputCsv2

#puts inputCsv2.size

#inputCsv2.each {|impt|
#	inputCsv1.delete_if{|x|
#		x[1] == impt[1]
#	}
#}

puts inputCsv1.size