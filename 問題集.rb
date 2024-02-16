#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'pp'

f = <<~EOS
q007_006_サポートチャレンジ_細胞の構造と機能
q010_002_要点整理_エネルギーの通貨としてのＡＴＰ
q011_010_サポートチャレンジ_ＡＴＰとＡＤＰの構造
q013_013_サポートチャレンジ_代謝の全体像
q014_001_要点整理_呼吸
q016_001_生物の共通性
q016_002_細胞の特徴
q017_003_生体とATP
q017_004_呼吸と光合成
q017_005_酵素のはたらき
EOS

outputAry = []

def formatOutput(str1,str2,str3)
	res = 'P.' + str1.to_i.to_s
	res += "\t"
	str3Ary = str3.split('_')
	if str3Ary.size == 2
		res += str3Ary[0] + str2.to_i.to_s + "\t" + str3Ary[1]
	elsif str3Ary.size == 1
		res += str2.to_i.to_s + "\t" + str3Ary[0]
	end
	return res
end

# ARGV.each do |f|
	f.dup.force_encoding("UTF-8").split("\n").each do |line|
		if /^q([0-9]+)_([0-9]+)_(.+)$/.match(line)
			outputAry << formatOutput($1,$2,$3)
		end #if
	end #each
# end #each
puts outputAry
# ^q([0-9]+)_([0-9]+)_(.+)$