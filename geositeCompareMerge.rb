#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

# usage: ruby csv2kml.rb input.csv format.kml output.kml
# ジオサイト一覧のCSVファイルから、
# require 'nkf'
# require 'yaml'
require 'pp'
require 'optparse'
require_relative 'CsvTableUtil.rb'

opt = OptionParser.new
params = {}
# opt.on('--orig VAL') {|v| v }
# opt.on('--mod VAL') {|v| v }
opt.on('--pref VAL') {|v| v }
opt.parse!(ARGV, into: params)

# p ARGV
# p params[:pref]

require params[:pref]

origFile = $origFile
modFile = $modFile
base_dir = $base_dir

if $switch == :short2short
	newHeaderStr = 'name,description,id,Latitude,Longitude'
	newHeaderAry = newHeaderStr.split(',').map {|n| n.to_sym}
	
	origTbl = origTable(origFile)
	modTbl = origTable(modFile)
	keysAry = [:id]
	
elsif $switch == :long2short
	headerCsv = "#{base_dir}/site_2024-10_h.csv"
	replHeaders = CSV.read(headerCsv)[1]
	replOrigTable = replaceHeaders(origFile, replHeaders)
	shortHeadersAry = [:name, :area, :lat, :lon, :temp_id]
	origTbl = selectTableCol(replOrigTable, shortHeadersAry)
	
	newHeaderAry = [:name, :area, :temp_id, :lat, :lon]
	modTbl = replaceHeaders(modFile, newHeaderAry)
	keysAry = [:temp_id]
end
# origTbl
# modTbl
# keysAry

origData = pivotedTable2Data(origTbl, keysAry)
modData = pivotedTable2Data(modTbl, keysAry)
dataDiff = diffData(origData, modData)
dataDiff.each {|key, value|
	p key
	pp makeTableByHash(newHeaderAry, value).to_csv
}

=begin
{{id: "108"} => {name: "ゴトロ浜", description: "飛島", Latitude: "39.183086", Longitude: "139.542649"},
 {id: "122"} => {name: "にかほ市関のタブ・シナノキ混生群落", description: "にかほ", Latitude: "39.189545", Longitude: "139.9103"},
 {id: "120"} => {name: "にかほ市金浦のタブノキ林", description: "にかほ", Latitude: "39.26188", Longitude: "139.92225"},
 {id: "121"} => {name: "にかほ市川袋のタブの群落", description: "にかほ", Latitude: "39.15641", Longitude: "139.89909"},

# メイン処理
# if ARGV.length < 2
#   puts "使い方: ruby geosite_csv2kml.rb input.csv output.kml"
#   exit
# end


=end