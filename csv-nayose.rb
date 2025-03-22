#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

# usage: ruby guide_overlap_check.rb input.csv
# 

require 'csv'
require 'pp'


#inputFile = ARGV.shift
inputFile_base = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/20250127湧水調査/共有用測定記録-表1のコピー.csv'
inputFile_data = '/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring_kml.csv'
inputCsvBase = CSV.read(inputFile_base, headers: true)
inputCsvData = CSV.read(inputFile_data, headers: true)

def normalize(str)
	return str.chomp.sub(/[（\(].+[）\)]$/, '')
end #def

def sameItem(ary1, ary2)
	sameItemAry = []
	ary1.each {|item|
		if ary2.include?(item)
			sameItemAry << item
		end #if
	}
#	return ary1 & ary2
	return sameItemAry
end #def

#データのない列は削除
inputCsvBase.by_col!.delete_if {|column_name, values|
	!column_name && values.none?
}

baseHeaders = inputCsvBase.headers
dataHeaders = inputCsvData.headers
#つなげた列名
returnHeaders = baseHeaders + dataHeaders
#outputCSVString = CSV::generate_line(returnHeaders)
returnHeadersRow = CSV::Row.new(returnHeaders, [], header_row: true)
outputCSV = CSV::Table.new([returnHeadersRow])


inputCsvBase.by_row!.each {|baseRow|
	returnRow = baseRow
	inputCsvData.each_with_index {|dataRow, idx|
		if baseRow['名称'] == normalize(dataRow['place_name'])
			dataRow.each {|item|
				returnRow << item
			}
			inputCsvData.delete(idx)
		end #if
	}
	outputCSV << returnRow
}

IO.write('/Users/hatanaka/Dropbox/遊佐町/水資源条例/spring.csv', outputCSV)
IO.write('/Users/hatanaka/Dropbox/遊佐町/水資源条例/unfit.csv', inputCsvData)
#print outputCSV.to_csv
exit

baseNameAry = inputCsvBase.by_col['名称']
dataNameAry = inputCsvData.by_col['place_name']
dataNameAry_Nrm = dataNameAry.map{|n| normalize(n)}

returnAry =

#共通
sameNameItemAry = sameItem(baseNameAry, dataNameAry_Nrm)
pp sameNameItemAry
pp sameNameItemAry.count
#共通部分以外
pp baseNameAry - sameNameItemAry
pp (baseNameAry - sameNameItemAry).count
pp dataNameAry_Nrm - sameNameItemAry
pp (dataNameAry_Nrm - sameNameItemAry).count

#pp inputCsvBase.headers

=begin

guideHash = {}
inputCsv.each { |aGuide|
	if guideHash[aGuide['案内人氏名']].nil?
		guideHash[aGuide['案内人氏名']] = {'案内人携帯' => aGuide['案内人携帯'], 'メールアドレス' => aGuide['メールアドレス']}
	else
		if guideHash[aGuide['案内人氏名']]['案内人携帯'] != aGuide['案内人携帯']
			puts aGuide['案内人氏名']
			puts " : #{guideHash[aGuide['案内人氏名']]['案内人携帯']}"
			puts " : #{aGuide['案内人携帯']}"
			puts ' - - - - - '
		elsif guideHash[aGuide['案内人氏名']]['メールアドレス'] != aGuide['メールアドレス']
			puts aGuide['案内人氏名']
			puts " : #{guideHash[aGuide['案内人氏名']]['メールアドレス']}"
			puts " : #{aGuide['メールアドレス']}"
			puts ' - - - - - '
		end #if
	end #if
}
pp guideHash
#inputCsv.headers


=end