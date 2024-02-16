#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

require 'csv'
require 'pp'

input =<<EOS
トンボ目
	ムカシヤンマ
バッタ目
	ミカドフキバッタ
	ヤブキリ種群 幼虫
カメムシ目
	エゾハルゼミ
	アカスジキンカメムシ
ハチ目
	ヒメマルハナバチ
	コマルハナバチ
	クロクサアリ属 sp.
	エゾクシケアリ
	ムネアカオオアリ
コウチュウ目
	オオセンチコガネ
	アオジョウカイ
	カシルリオトシブミ
	ツチハンミョウ
	ヒゲナガオトシブミ
	アオハムシダマシ
チョウ目
	ヨシカレハ幼虫
	スグリシロエダシャク
	マイマイガ幼虫
	イチモンジチョウ
	クロヒカゲ
	ヤマキマダラヒカゲ
	キアゲハ
ハエ目
	キアシオオブユ
	ビロウドツリアブ
	オオイシアブ
EOS

output = []
item1 = ''
input.split("\n").each {|line|
	if line =~ /^\S/ # 非空白文字から始まる
		item1 = line
	else # 空白文字から始まる
		output << item1 + line
	end #if
}

puts output.join("\n")
