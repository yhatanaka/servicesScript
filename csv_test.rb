#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"
require 'csv'
require 'pp'

inputFile = '/Users/hatanaka/Downloads/Ｒ04 認定ガイド名簿【遊佐】/会員-1-表1.csv'
tableKey = [:'氏名']
tableHeadersStr = 'No.,＃,氏名,電話番号,メール,期,遊佐,備　考,遊佐'
tableHeadersAry = tableHeadersStr.split(',').map {|n| n.to_sym}

header_converter = lambda {|h| h.to_sym}
table = CSV.read(inputFile, headers: true, skip_blanks: true, header_converters: header_converter)

# 縦持ちにした時の、key 項目以外のヘッダ名
@unpivotedExtraHeaders = [:key, :value]
# 縦持ちに
def unpivot(table, keysAry)
# 縦持ちのヘッダ、(keysAry の各項目), unpivotedExtraHeaders
	newHeadersAry = keysAry + @unpivotedExtraHeaders
# 最終的なデータ
	outputRowsAry = []

	table.each {|row|
# この行の key 項目のデータを入れる
		keyCols = []
		rowHash = row.to_h
# key 項目それぞれで…
		keysAry.each {|keyHeader|
# key 項目のデータを格納し…
			keyCols << rowHash[keyHeader]
# 格納したら行のデータからは削除
			rowHash.delete(keyHeader)
		}
# 残ったもの、つまり行の key 項目「以外」のヘッダ名と値を…
		rowHash.each {|key, value|
# 値が nil でなければ
			if value
				outputRow = []
# ヘッダ名と値を…
				outputRow.push(key,value)
# key 項目に続けて、1行できあがり
				outputRowsAry << keyCols + outputRow
			end
		}
	}
#	pp keysAry.push(:key)
# 行のデータと、ヘッダから table 作る
	return makeTable(newHeadersAry, outputRowsAry)
end
# 配列の配列と、ヘッダの配列から、CSV::table へ変換
def makeTable(headersAry, bodyAryOfAry)
	bodyRowAry = []
	bodyAryOfAry.each {|bodyRow|
		bodyRowAry << CSV::Row.new(headersAry, bodyRow)
	}
	return CSV::Table.new(bodyRowAry)
end

# 横持ちに
def pivot(table, keysAry, headersAry = nil)
	# rowsAry = []
	keysHash = {}

	if headersAry  # headersAry 指定すると、その順番に列を出力
		pivotedHeadersName = headersAry
	else  # 指定されなければ…
# 横持ちの場合の key 以外の項目名
		extraPivotedHeadersName = table[:key].uniq
# 最終的なヘッダは、key 項目 + (:key 列のuniq)
		pivotedHeadersName = keysAry + extraPivotedHeadersName
	end

# 行ごとに…
	table.each {|row|
		rowHash = row.to_h
# この行の key 項目を入れる準備
		thisRowKeysHash = {}
# key 項目ごとに…
		keysAry.each {|key|
# この行から拾って入れる
			thisRowKeysHash[key] = rowHash[key]
# 入れたら元の行データからは削除
			rowHash.delete(key)
		}
# この key 項目は初めて出たんなら、追加のデータ入れる準備
		unless keysHash[thisRowKeysHash]
			keysHash[thisRowKeysHash] = thisRowKeysHash.dup
		end

# 残りのヘッダは、unpivotedExtraHeaders
# {["おれ", "今日"] => {昼食: "ラーメン", 夕食: "牛丼"},
# ["おれ", "昨日"] => {朝食: "梅干しご飯", おやつ: "ポテチ", 夕食: "ラーメン"},
# ["おれ", "一昨日"] => {朝食: "食パン", 昼食: "焼き魚定食", 夕食: "麻婆豆腐定食"},
# …}
		keysHash[thisRowKeysHash][rowHash[:key]] = rowHash[:value]
	}

	resultAry = keysHash.each_with_object([]) {|(prmKeys, itemHash), newAry|
		rowAry = []
		# pivotedHeadersName.each {|extraKey|
		# 	rowAry << extraHash[extraKey]
		# }
		rowAry = pivotedHeadersName.map {|key|
			itemHash[key]
		}
		newAry << rowAry
	}

	newHeaders = pivotedHeadersName
	return makeTable(newHeaders, resultAry)
end

unpivoted = unpivot(table, tableKey)
pp unpivoted
pivoted = pivot(unpivoted, tableKey, tableHeadersAry)
pp pivoted

