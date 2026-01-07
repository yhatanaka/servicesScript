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
opt.on('--orig VAL') {|v| v }
opt.on('--mod VAL') {|v| v }
opt.parse!(ARGV, into: params)


# p ARGV
# p params
base_dir = '/Users/hatanaka/Dropbox/ジオパーク/2024_サイト再設定/site_2024-10'

origFile = "#{base_dir}/site_2024-10.csv"
headerCsv = "#{base_dir}/site_2024-10_h.csv"

modFile = "#{base_dir}/2026-01-07.csv"
# マージするCSV (modFile) のヘッダを置き換えるヘッダ
# 'name,description,id,Latitude,Longitude'
# newHeadersStr = 'name,area,temp_id,Lat,Lon'
# newHeaders = newHeadersStr.split(',').map {|n| n.to_sym}
newHeaders = [:name, :area, :temp_id, :lat, :lon]

replHeaders = CSV.read(headerCsv)[1]
replOrigTable = replaceHeaders(origFile, replHeaders)
shortHeadersAry = [:name, :area, :lat, :lon, :temp_id]
siteCsvShort = selectTableCol(replOrigTable, shortHeadersAry)

unpivotOrig = unpivot(siteCsvShort, [:temp_id])
pp unpivotOrig
pivotOrig = pivot(unpivotOrig, [:temp_id], shortHeadersAry)
# pp pivotOrig

replModTable = replaceHeaders(modFile, newHeaders)
unpivotMod = unpivot(replModTable, [:temp_id])
pivotMod = pivot(unpivotMod, [:temp_id], newHeaders)
pp unpivotMod

exit





base_dir = '/Users/hatanaka/Dropbox/ジオパーク/2024_サイト再設定/site_2024-10'
inputFile = "#{base_dir}/site_2024-10.csv"
# inputFile = ARGV.shift
# formatFile = '/Users/hatanaka/Dropbox/ジオパーク/geosite_format.kml'
# formatFile = ARGV.shift
# outputFile = ARGV.shift
outputKml1 = "#{base_dir}/site_2024-10.kml"
outputKml2 = "#{base_dir}/site_2024-10_undicided.kml"

outputJson1 = "#{base_dir}/site_2024-10.geojson"
outputJson2 = "#{base_dir}/site_2024-10_undicided.geojson"


# outputType = :kml
outputType = :geojson

# 出力する項目名
# outputColumnsAry = [:name, :lat, :lon]

# メイン処理
# if ARGV.length < 2
#   puts "使い方: ruby geosite_csv2kml.rb input.csv output.kml"
#   exit
# end

# input_file = ARGV[0]
# output_file = ARGV[1]



locAry = []
nolocAry = []
nolocHash = {}
siteCsvShort.each do |feature|
	if feature[:name]
		if !feature[:lat] || !feature[:lon]
# カウント用
			if !nolocHash[feature[:area]]
				nolocHash[feature[:area]] = 1
			else
				nolocHash[feature[:area]] += 1
			end
			distStep = 0.004 # 各点、おおよそこの4倍くらい離れる
			noLocPlaceAry = placeFibonacci(areaCenterHash[feature[:area]], nolocHash[feature[:area]]-1, distStep)
			feature[:lat] = noLocPlaceAry[0]
			feature[:lon] = noLocPlaceAry[1]
				nolocAry << feature
		else
				locAry << feature
		end
	end
end
# カウント用
# pp nolocHash
# exit


if outputType == :kml
	docs = [document1, document2]
	[locAry, nolocAry].each_with_index {|features, idx|
		features.each {|feature|
			feature4KML = {:type => 'Point', :coordinates => [feature[:lon], feature[:lat]], :option => {'name' => feature[:name], 'description' => feature[:area]}}
			geometry_to_kml(docs[idx], feature4KML)
		}
	}
	
	[[outputKml1, doc1], [outputKml2, doc2]].each {|item|
		File.open(item[0], 'w') do |file|
			formatter = REXML::Formatters::Pretty.new(2)
			# formatter.compact = true
			formatter.write(item[1], file)
		end
	}
	
	puts "KMLファイルを出力しました: #{outputKml1}, #{outputKml2}"
elsif outputType == :geojson
	require_relative 'geojsonUtil.rb'
	outputJsonAry = [outputJson1, outputJson2]
	[locAry, nolocAry].each_with_index {|features, idx|
		features4json = features.map {|feature|
			{:type => 'Point', :coordinates => [feature[:lon], feature[:lat]], :properties => {'name' => feature[:name], 'description' => feature[:area], 'id' => feature[:temp_id]}}
		}
		jsonData = makeFeatureCollection(features4json)
# GeoJSONをファイルに書き出し
		File.open(outputJsonAry[idx], 'w') do |f|
			# 見やすいように整形して書き出す
			f.write(JSON.pretty_generate(jsonData))
		end
		puts "\n処理が完了しました。"
		puts "出力ファイル: #{outputJsonAry[idx]}"
		puts "Feature数: #{features.size}"
	}
end
