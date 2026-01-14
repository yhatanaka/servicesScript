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
# [['泥沢', 'モノサシトンボ'], ['泥沢', 'コバネイバゴ'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'モリアオガエル'], ['藤井公園', 'カナヘビ'], ['ハッチョウ', 'モリアオガエル'], ['ハッチョウ', 'ハッチョウトンボ']]
def locSpArys(text, pickDepthAry)
	# 空行を除去して行ごとの配列にする
	lines = text.lines.map(&:chomp).reject(&:empty?)
	
	# 現在の階層パスを保持する配列
	current_path = []
# [[調査地1, 種1], [調査地1, 種2], ... [調査地n, 種m]]
	locSpeciesAryInAry = []

	lines.each_with_index do |line, index|
		# 行頭のタブの数を数えて階層の深さ(depth)とする
		depth = line[/\A\t*/].size
		if pickDepthAry[depth]
			content = line.strip
			# その深さに対応する位置(pickDepthAry)に現在の項目をセットする
			current_path[pickDepthAry[depth]] = content
			
			# 以前の深い階層のデータが残らないように、現在の深さまでで配列を切り取る
			current_path = current_path[0..pickDepthAry[depth]]
	
			# --- ここから「葉（末端）」かどうかの判定 ---
		end
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
		# 末端の場合のみ、locSpeciesAryInAry に current_path 追加
		if is_leaf
# 配列に追加した値が、その後の処理中に変化しないよう、dup してから追加
			locSpeciesAryInAry << current_path.dup
			# puts current_path.join("\t")
		end
	end
	return locSpeciesAryInAry
end

# {'モノサシトンボ' => ['泥沢'], 'コバネイバゴ' => ['泥沢'], 'モリアオガエル' => ['藤井公園', 'ハッチョウ'], 'カナヘビ' => ['藤井公園'], 'ハッチョウトンボ' => ['ハッチョウ']}
def makeSp2LocHash(locSpArys)
	retHash = {}
	locSpArys.each {|aLocSpAry|
# すでに登録済みの種で、まだその調査地がなければ
		if retHash[aLocSpAry[1]] && !retHash[aLocSpAry[1]].include?(aLocSpAry[0])
			retHash[aLocSpAry[1]] << aLocSpAry[0]
		else
# 初出の種なら、{種名 => [地名]}
			retHash[aLocSpAry[1]] = [aLocSpAry[0]]
		end
	}
	return retHash
end

# 種名リストの重複チェック
def checkDupSpList(tbl)
	ret2 = tbl.by_col
	sps = ret2[:種]
# value1 => [value1], value2 => [value2, value2]
# 値の要素数が1より大きいもの選んで(value2 => [value2, value2])
# 
	ret = sps.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
	# ret = sps.select{ |e| sps.count(e) > 1 }.uniq
	return ret
end

# tbl の種名 spName の行番号(1〜)を返す
def whereSpList(tbl, spName)
	ret = []
	tbl.each_with_index {|row, idx|
		if row[:種] == spName
			ret << idx + 1
		end
	}
	ret
end

pickData = File.read(pickFile)
pp locSpArys(pickData, pickDepthAry)
# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end