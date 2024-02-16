#!/usr/bin/ruby

input =<<EOS
6000	副会長(2)	8,000
12,000 副部長(4)	8,000
6,000隣組長⑶	16,000
2.000

EOS

# カッコ付数字「(3)」削除、数字と「,」「.」(←OCR誤認識対策)以外で切り分け、空文字列削除、OCR誤認識の「.」を「,」に置換
aFormulaAry = input.gsub(/[\(（][0-9][\)）]/,'').split(/[^0-9,\.]+/).delete_if {|x| x==''}.map {|x| x.gsub(/[,\.]/,',')}
# 足し算の式
aFormulaStr = aFormulaAry.join(' + ')

pp aFormulaStr

# 「,」を削除し、自然数に
aFormulaIntAry = aFormulaAry.map {|x| x.gsub(/,/,'').to_i}

# 足す
aFormulaResult = 0
aFormulaIntAry.each {|x|
	aFormulaResult += x
}
pp aFormulaResult
