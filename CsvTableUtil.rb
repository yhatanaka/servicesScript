require 'csv'

# class CsvTableUtil < CSV

	# attr_accessor :outputColumnsAry
	# attr_reader :inputCsv, :origTable, :headerCsv, :repTable, :selectedTable
	
	# def initialize(inputFile = nil)
	# 	@inputCsv = inputFile
	# end
	
	def origTable(inputCsv)
		origTable = CSV.read(inputCsv, headers: true, header_converters: :symbol_raw)
		return origTable
	end
	
	def origHeader(inputCsv)
		firstRow = CSV.foreach(inputCsv){ |row| break row }
	end
	
	def replaceHeaders(inputCsv, replHeaders)
		# Header 置き換え 置き換えたい項目書いたHeader 読む。nil の部分は元のそのままにする
		newHeaders = []
		origHeaders = origHeader(inputCsv)
		origHeaders.each_with_index {|n,idx|
			if replHeaders[idx]
				newItem = replHeaders[idx].to_sym
			else
				newItem = n
			end
			newHeaders << newItem
		}
		# ファイルに書き込む場合
		# CSV.filter(inputCsv, :headers => true, :out_headers => newHeaders, :write_headers => true) do |row|
		# end
		
		replHeaders_dict = origHeaders.zip(newHeaders).to_h
		replConverter = lambda { |h| replHeaders_dict[h] }
		
		# CSV.table だけだと日本語表示されないので、option つける
		repTable = CSV.read(inputCsv, headers: true, header_converters: [replConverter, :symbol_raw])
		return repTable
	end
	# dataTable = CSV.table(inputFile, header_converters: :symbol_raw)
	# dataTable = CSV.read(inputFile)
	def selectTableCol(aTable, colAry)
		# 出力する項目名
		outputColumnsAry = colAry
		# それ以外を削除したCSV Table
		dataTable = aTable.by_col.select {|header, value|
			outputColumnsAry.include?(header)
		}
		retHash = {:headers => [], :rowsAry => []}
		dataTable.each {|eachCol|
			retHash[:headers] << eachCol[0]
			eachCol[1].each_with_index {|colItem, row|
				if retHash[:rowsAry][row]
					retHash[:rowsAry][row] << colItem
				else
					retHash[:rowsAry][row] = [colItem]
				end
			}
		}
		headerRow = CSV::Row.new(retHash[:headers], [], header_row: true)
		aTable = CSV::Table.new([headerRow])
		aTable.push(*retHash[:rowsAry])
		return aTable
	end
# dataTable2.delete_if {|header, value|
# 	!outputColumnsAry.include?(header)
# }
# dataTable2.by_row!
# # dataTable2.by_col_or_row!
# dataTable2.delete_if {|row|
# 	row[:lat] || row[:lon]
# }

# [
#  [:colname1, [row1_1, row2_1, row3_1,...]]
#  ,[:colname2, [row1_2, row2_2, row3_2,...]]
#  ,...
# ]
# →
# [colname1, colname2, ...]
# [row1_1, row1_2, ...]
# [row2_1, row2_2, ...]
# [row3_1, row3_2, ...]
# ...
# end

# 縦持ち・横持ち変換
# tableKey = [:'氏名']
# tableHeadersStr = 'No.,＃,氏名,電話番号,メール,期,遊佐,備　考,遊佐'
# tableHeadersAry = tableHeadersStr.split(',').map {|n| n.to_sym}
# unpivoted = unpivot(table, tableKey)
# pivoted = pivot(unpivoted, tableKey, tableHeadersAry)


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
