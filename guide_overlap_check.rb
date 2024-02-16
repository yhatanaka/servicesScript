#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# ガイド受付システムからExportしたガイドのCSVファイルから、同姓同名の人がいないかチェック

require 'csv'
require 'pp'


inputFile = ARGV.shift
#inputFile = '/Users/hatanaka/Dropbox/ジオパーク/ガイドの会/2024-01-05_UTF8.csv'
inputCsv = CSV.read(inputFile, headers: true)

guideHash = {}
inputCsv.each { |aGuide|
	if guideHash[aGuide['案内人氏名']].nil?
		guideHash[aGuide['案内人氏名']] = {'案内人携帯' => aGuide['案内人携帯'], 'メールアドレス' => aGuide['メールアドレス']}
	else
		if guideHash[aGuide['案内人氏名']]['案内人携帯'] != aGuide['案内人携帯']
			puts aGuide['案内人氏名']
			puts " : #{guideHash[aGuide['案内人氏名']]['案内人携帯']}"
			puts " : #{aGuide['案内人携帯']}"
			puts ' - - - - - '
		elsif guideHash[aGuide['案内人氏名']]['メールアドレス'] != aGuide['メールアドレス']
			puts aGuide['案内人氏名']
			puts " : #{guideHash[aGuide['案内人氏名']]['メールアドレス']}"
			puts " : #{aGuide['メールアドレス']}"
			puts ' - - - - - '
		end #if
	end #if
}
pp guideHash
#inputCsv.headers

=begin

=end