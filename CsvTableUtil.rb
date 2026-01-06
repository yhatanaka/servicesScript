class CsvTableUtil
	require 'csv'

	attr_accessor :outputColumnsAry
	attr_reader :inputCsv, :origTable, :headerCsv, :repTable, :selectedTable
	
	def initialize(inputFile)
		@inputCsv = inputFile
	end
	
	def origTable()
		@origTable = CSV.read(@inputCsv, headers: true, header_converters: :symbol_raw)
		return @origTable
	end
	
	def replaceHeaders(headerCsv)
		# Header 置き換え
		@headerCsv = headerCsv
		replHeaders = CSV.read(headerCsv)
		# headerCsv 1行目、置き換えたい(データCSVの)ヘッダ
		origHeaders = replHeaders[0]
		newHeaders = []
		origHeaders.each_with_index {|n,idx|
			if replHeaders[1][idx]
				newItem = replHeaders[1][idx].to_sym
			else
				newItem = n
			end
			newHeaders << newItem
		}
		# ファイルに書き込む場合
		# CSV.filter(inputCsv, :headers => true, :out_headers => newHeaders, :write_headers => true) do |row|
		# end
		
		headers_dict = origHeaders.zip(newHeaders).to_h
		converter = lambda { |h| headers_dict[h] }
		
		# CSV.table だけだと日本語表示されないので、option つける
		@repTable = CSV.read(@inputCsv, headers: true, header_converters: [converter, :symbol_raw])
		return @repTable
	end
	# dataTable = CSV.table(inputFile, header_converters: :symbol_raw)
	# dataTable = CSV.read(inputFile)
	def selectTableCol(colAry)
		# 出力する項目名
		@outputColumnsAry = colAry
		# それ以外を削除したCSV Table
		dataTable = @repTable.by_col.select {|header, value|
			@outputColumnsAry.include?(header)
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
end