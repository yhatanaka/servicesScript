#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby csv2vCard.rb input.csv output.vcf

require 'csv'

inputFile = ARGV.shift
outputFile = ARGV.shift

dataTable = CSV.read(inputFile)
outputArray = []

columnName = dataTable[0]
dataTable.shift
# pp dataTable
dataAry =[]
dataTable.each {|member|
	dataAry.push(columnName.zip(member).to_h)
# 	dataAry.push([columnName,member].to_h)
}
# pp dataAry
vc = ''
dataAry.each {|member|
	vc1 = <<-EOS
BEGIN:VCARD
VERSION:3.0
PRODID:-//Apple Inc.//macOS 12.2//EN
N:#{member['性']};#{member['名']};;;
FN:#{member['名']} #{member['性']}
X-PHONETIC-FIRST-NAME:#{member['名読み']}
X-PHONETIC-LAST-NAME:#{member['性読み']}
EMAIL;type=INTERNET;type=HOME;type=pref:#{member['メールアドレス']}
	EOS
	if member['携帯メール'] then
		vc1 += <<-EOS
item1.EMAIL;type=INTERNET:#{member['携帯メール']}
item1.X-ABLabel:携帯メール
		EOS
	end #if
	vc1 += <<-EOS
TEL;type=HOME;type=VOICE:#{member['電話番号']}
TEL;type=CELL;type=VOICE:#{member['携帯電話']}
ADR;type=HOME;type=pref:;;#{member['住所']};#{member['市町村']};山形県;#{member['郵便番号']};
		EOS
	if member['メモ'] then
		vc1 += <<-EOS
NOTE:#{member['メモ']}
		EOS
	end #if
	vc1 += <<-EOS
END:VCARD
	EOS
	vc += vc1
}
print vc