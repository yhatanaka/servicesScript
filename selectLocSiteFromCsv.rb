#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

# usage: ruby selectLocSiteFromCsv.rb input.csv
# 座標入ってるサイトを、(座標を小数点以下5桁にして) geojson で出力
# ジオサイト一覧のCSVファイルから、
# require 'nkf'
# require 'yaml'
require 'pp'

require_relative 'CsvTableUtil.rb'

inputFile = ARGV.shift

base_dir = '/Users/hatanaka/Dropbox/ジオパーク/2024_サイト再設定/site_2024-10'
headerCsv = "#{base_dir}/site_2024-10_h.csv"
replHeaders = CSV.read(headerCsv)[1]

replTable = replaceHeaders(inputFile, replHeaders)

# 出力する項目名
siteCsvShort = selectTableCol(replTable, [:name, :area, :lat, :lon, :temp_id])

locAry = []
siteCsvShort.each do |feature|
	if feature[:name]
		if feature[:lat] && feature[:lon]
			feature[:lat] = feature[:lat].round(5)
			feature[:lon] = feature[:lon].round(5)
				locAry << feature
		end
	end
end

require_relative 'geojsonUtil.rb'
features4json = locAry.map {|feature|
	{:type => 'Point', :coordinates => [feature[:lon], feature[:lat]], :properties => {'name' => feature[:name], 'description' => feature[:area], 'id' => feature[:temp_id]}}
}
jsonData = makeFeatureCollection(features4json)
# GeoJSONをファイルに書き出し
# File.open(outputJson, 'w') do |f|
# 	# 見やすいように整形して書き出す
# 	f.write(JSON.pretty_generate(jsonData))
# end
# puts "\n処理が完了しました。"
# puts "出力ファイル: #{outputJson}"
# puts "Feature数: #{locAry.size}"
puts JSON.pretty_generate(jsonData)