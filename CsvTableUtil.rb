require 'csv'

# class CsvTableUtil < CSV

	# attr_accessor :outputColumnsAry
	# attr_reader :inputCsv, :origTable, :headerCsv, :repTable, :selectedTable
	
	# def initialize(inputFile = nil)
	# 	@inputCsv = inputFile
	# end
	
	def origTable(inputCsv)
		origTable = CSV.table(inputCsv, headers: true, header_converters: :symbol_raw)
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
		repTable = CSV.table(inputCsv, headers: true, header_converters: [replConverter, :symbol_raw])
		return repTable
	end

	def selectTableCol(aTable, colAry)
		# 出力する項目名
		outputColumnsAry = colAry.map {|n| n.to_sym}
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
$unpivotedExtraHeaders = [:otherKey, :otherKeysValue]
# 横持ちのTableを縦持ちのTableに
def unpivot(table, keysAry)
	dataHash = pivotedTable2Data(table, keysAry)
	return data2UnpivotedTable(dataHash, keysAry)
end

# 横持ちのTableからDataに
def pivotedTable2Data(table, keysAry)
# 中間データ
	outputRowDataHash = {}

	table.each {|row|
# この行の key 項目のデータを入れる
		keyColsHash = {}
		rowHash = row.to_h
# key 項目それぞれで…
		keysAry.map{|n| n.to_sym}.each {|aKey|
# key 項目のデータを格納し…
			keyColsHash[aKey] = rowHash[aKey]
# 格納したら行のデータからは削除
			rowHash.delete(aKey)
		}
		outputRowDataHash[keyColsHash] = rowHash
	}
	return outputRowDataHash
# pp outputRowDataHash
end

# Dataから縦持ちのTableに
def data2UnpivotedTable(outputRowDataHash, keysAry)
# 縦持ちのヘッダ、(keysAry の各項目), unpivotedExtraHeaders
	newHeadersAry = keysAry.map{|n| n.to_sym} + $unpivotedExtraHeaders
# 最終的なデータ
	outputRowsAry = []
	outputRowDataHash.each {|keyHash, itemHash|
# 残ったもの、つまり行の key 項目「以外」のヘッダ名と値を…
		itemHash.each {|key, value|
# 値が nil でなければ
			if value
# 「key 項目、ヘッダ名、値」で1行できあがり
# Hash.keys/values は追加した順番に出力される
				outputRowsAry << keyHash.values + [key, value]
			end
		}
	}
# 行のデータと、ヘッダから table 作る
	return makeTable(newHeadersAry, outputRowsAry)
end

# 配列の配列と、ヘッダの配列から、CSV::table へ変換
def makeTable(headersAry, bodyAryOfAry)
	bodyRowsAry = []
	bodyAryOfAry.each {|bodyRow|
		bodyRowsAry << CSV::Row.new(headersAry, bodyRow)
	}
	return CSV::Table.new(bodyRowsAry)
end

# Hashの配列と、ヘッダの配列から、CSV::table へ変換
def makeTableByHash(headersAry, bodyAryOfHash)
	bodyRowsAry = []
	bodyAryOfHash.each {|bodyRow|
		bodyItemAry = []
		headersAry.each {|aHeader|
			bodyItemAry << bodyRow[aHeader]
		}
		bodyRowsAry << CSV::Row.new(headersAry, bodyItemAry)
	}
	return CSV::Table.new(bodyRowsAry)
end

# 縦持ちのTableから横持ちのTableに
def pivot(table, keysAry, headersAry = nil)
	dataHash = unpivotedTable2Data(table, keysAry)
	return data2PivotedTable(dataHash, headersAry)
end

# 縦持ちのTableからDataに
def unpivotedTable2Data(table, keysAry)
	keysHash = {}

# 行ごとに…
	table.each {|row|
		rowHash = row.to_h
# この行の key 項目を入れる準備
		thisRowKeysHash = {}
# key 項目ごとに…
		keysAry.map{|n| n.to_sym}.each {|key|
			keySym = 
# この行から拾って入れる
			thisRowKeysHash[key] = rowHash[key]
# 入れたら元の行データからは削除
			rowHash.delete(key)
		}
# この key 項目は初めて出たんなら、追加のデータ入れる準備
		unless keysHash[thisRowKeysHash]
			keysHash[thisRowKeysHash] = {}
		end

# 残りのヘッダは、unpivotedExtraHeaders
# {{:名前=>"おれ", :年月日=>"今日"}=>{:昼食=>"ラーメン", :夕食=>"牛丼"},
#  {:名前=>"おれ", :年月日=>"昨日"}=>{:朝食=>"梅干しご飯", :おやつ=>"ポテチ", :夕食=>"ラーメン"},
#  ...}
		keysHash[thisRowKeysHash][rowHash[$unpivotedExtraHeaders[0]].to_sym] = rowHash[$unpivotedExtraHeaders[1]]
	}
	return keysHash
end

# Dataから横持ちのTableに
def data2PivotedTable(dataHash, headersAry = nil)
	if headersAry  # headersAry 指定すると、その順番に列を出力
		pivotedHeadersName = headersAry.map{|n| n.to_sym}
	else  # 指定されなければ…
# 横持ちの場合の key 以外の項目名
		extraPivotedHeadersName = table[$unpivotedExtraHeaders[0]].uniq
# 最終的なヘッダは、key 項目 + (:key 列のuniq)
		pivotedHeadersName = keysAry + extraPivotedHeadersName
	end

	resultAry = dataHash.each_with_object([]) {|(keysHash, itemHash), newAry|
		rowAry = []
		mergedHash = keysHash.merge(itemHash)
		rowAry = pivotedHeadersName.map {|key|
			mergedHash[key]
		}
		newAry << rowAry
	}
	newHeaders = pivotedHeadersName
	return makeTable(newHeaders, resultAry)
end

def diffData(bfrData, aftData)
# 付け加えられた行、変更された行、元の方にしかない行
	newRowAry = []
	modRowAry = []
	deletedRowAry = []
	aftData.each {|keyHash, itemHash|
		if bfrData[keyHash] # 元のデータにあるもの
			if itemHash != bfrData[keyHash]
				modRowAry << keyHash.merge(itemHash)
			end
			# itemHash.each {|itemKey, itemValue|
			# 	bfrData[keyHash][itemKey] 
			# }
			# 	modRowAry << keyHash.merge(itemHash)
			bfrData.delete(keyHash)
		else # 付け加えられた行
			newRowAry << keyHash.merge(itemHash)
		end
	}
	bfrData.each {|keyHash, itemHash|
		deletedRowAry << keyHash.merge(itemHash)
	}
	return {:deleted => deletedRowAry, :new => newRowAry, :mod => modRowAry} # old はHash, 残りはArray
end