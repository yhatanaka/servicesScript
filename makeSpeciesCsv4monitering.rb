#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

# usage: ruby this.rb 調査結果.txt 種名のストック.csv
# タブで階層化された
# "項目1
# 	項目1-1
# 	項目1-2
# 		項目1-2-1
# 項目2
# 項目3
# 	項目3-1
# "
# を、表形式に
# "項目1	項目1-1
# 項目1	項目1-2	項目1-2-1
# 項目2
# 項目3	項目3-1
# "
# のように変換する ruby スクリプト

# 泥沢	ノシメトンボ
# 泥沢	ヤマトシリアゲ
# 藤井公園	キタキチョウ
# 藤井公園	ツバメシジミ
# 藤井公園	エンマコオロギ

# require 'nkf'
# require 'yaml'
require 'pp'
require 'optparse'

require_relative 'CsvTableUtil.rb'

opt = OptionParser.new
params = {}
# opt.on('--orig VAL') {|v| v }
# opt.on('--mod VAL') {|v| v }
opt.on('--pick VAL') {|v| v }
opt.on('--from VAL') {|v| v }
opt.parse!(ARGV, into: params)


# pickFile = params[:pick]
# fromFile = params[:from]
# タブでインデント
pickFile = '/Users/hatanaka/Dropbox/モニタリング調査/モニタリング2025/2025年モニタリング概要.txt'
pickDepthAry = [0,nil,1]
fromFile = '/Users/hatanaka/Dropbox/モニタリング調査/モニタリング2025/リスト/シート1-表1.csv'


begin
# 処理ロジック
def convert_to_table(text, pickDepthAry)
	# 空行を除去して行ごとの配列にする
	lines = text.lines.map(&:chomp).reject(&:empty?)
	
	# 現在の階層パスを保持する配列
	current_path = []

	lines.each_with_index do |line, index|
		# 行頭のタブの数を数えて階層の深さ(depth)とする
		depth = line[/\A\t*/].size
		content = line.strip

		if pickDepthAry[depth]
			# その深さに対応する位置(pickDepthAry)に現在の項目をセットする
			current_path[pickDepthAry[depth]] = content
			
			# 以前の深い階層のデータが残らないように、現在の深さまでで配列を切り取る
			current_path = current_path[0..pickDepthAry[depth]]
	
			# --- ここから「葉（末端）」かどうかの判定 ---
			
			# 次の行を取得（なければnil）
			next_line = lines[index + 1]
			is_leaf = false
	
			if next_line.nil?
				# 次の行がない＝最後の行なので末端
				is_leaf = true
			else
				# 次の行のインデントを調べる
				next_depth = next_line[/\A\t*/].size
				
				# 次の行が現在の行より深くない（同じか浅い）場合、現在の行は末端
				if next_depth <= depth
					is_leaf = true
				end
			end
		else
			next
		end
		# 末端の場合のみ、パスをタブ区切りで結合して出力
		if is_leaf
			puts current_path.join("\t")
		end
	end
end

pickData = File.read(pickFile)
convert_to_table(pickData, pickDepthAry)
# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end
exit
# open(inputFile,'r') do |inFile|

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