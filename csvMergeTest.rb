#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'pp'
require_relative 'CsvTableUtil.rb'

inputFile = '/Users/hatanaka/Documents/servicesScript/csv_test.csv'

origCsv = origTable(inputFile)
pp origCsv
unpivotCsv = unpivot(origCsv, [:名前, :年月日])
pp unpivotCsv

origHeadersStr = '名前,年月日,朝食,昼食,おやつ,夕食'
prigHeadersAry = origHeadersStr.split(',').map {|n| n.to_sym}

repivotCsv = pivot(unpivotCsv, [:名前, :年月日], prigHeadersAry)
pp repivotCsv

data = pivotedTable2Data(origCsv, [:名前, :年月日])
reTable = data2PivotedTable(data, prigHeadersAry)
pp reTable
exit

{{:名前=>"おれ", :年月日=>"今日"}=>{:昼食=>"ラーメン", :夕食=>"牛丼"},
 {:名前=>"おれ", :年月日=>"昨日"}=>{:朝食=>"梅干しご飯", :おやつ=>"ポテチ", :夕食=>"ラーメン"},
 {:名前=>"おれ", :年月日=>"一昨日"}=>{:朝食=>"食パン", :昼食=>"焼き魚定食", :夕食=>"麻婆豆腐定食"},
 {:名前=>"あいつ", :年月日=>"一昨日"}=>{:朝食=>"納豆ご飯", :おやつ=>"アイス", :夕食=>"ラーメン"},
 {:名前=>"あいつ", :年月日=>"昨日"}=>{:昼食=>"そうめん", :おやつ=>"ピザ", :夕食=>"ラーメン"},
 {:名前=>"そいつ", :年月日=>"今日"}=>{:朝食=>"ご飯・味噌汁", :昼食=>"ラーメン", :夕食=>"牛丼"},
 {:名前=>"そいつ", :年月日=>"昨日"}=>{:朝食=>"納豆ご飯", :昼食=>"焼き魚定食", :夕食=>"ラーメン"},
 {:名前=>"そいつ", :年月日=>"一昨日"}=>{:朝食=>"食パン", :昼食=>"麻婆豆腐定食", :おやつ=>"アイス", :夕食=>"ラーメン"},
 {:名前=>"知らんやつ", :年月日=>"今日"}=>{:昼食=>"ラーメン", :おやつ=>"ポテチ"},
 {:名前=>"知らんやつ", :年月日=>"昨日"}=>{:朝食=>"食パン", :おやつ=>"ポテチ", :夕食=>"ラーメン"},
 {:名前=>"誰か", :年月日=>"一昨日"}=>{:朝食=>"梅干しご飯", :昼食=>"ラーメン", :夕食=>"ラーメン"}}
