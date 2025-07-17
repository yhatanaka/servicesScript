# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"
require 'csv'
require 'open3'

inputFile = ARGV.shift
inputFileDir = File.dirname(inputFile)
inputFileNameWOExt = File.basename(inputFile, ".*")
grdFile = inputFileDir + '/' + inputFileNameWOExt + '.grd'

contents = File.read(inputFile)
headersAry = ['lon','lat','depth']
rtnHeadersRow = CSV::Row.new(headersAry, [], header_row: true)
outputCSV = CSV::Table.new([rtnHeadersRow])

contents.split("\n").each {|row|
	rowAry = row.split(/\s+/)
	outputAry = [rowAry[2].to_f, rowAry[1].to_f, rowAry[3].to_f * -1]
	outputCSV << CSV::Row.new(headersAry, outputAry)
}
lonAry = outputCSV.by_col['lon']
lonAry.delete_at(0)
lonMinMax = lonAry.minmax
latAry = outputCSV.by_col['lat']
latAry.delete_at(0)
latMinMax = latAry.minmax


#p IO.popen("cat", "r+") {|io|
#	io.write outputCSV.to_csv
#	io.gets
#}


o, e, s = Open3.capture3("gmt nearneighbor -G#{grdFile} -I500e -S3k -V -R#{lonMinMax[0]}/#{lonMinMax[1]}/#{latMinMax[0]}/#{latMinMax[1]}", :stdin_data=>outputCSV.to_csv)
p o
p e
#p s
exit

exec("gmt nearneighbor hoge.txt -Gout.grd -I500e -S3k -V -R#{lonMinMax[0]}/#{lonMinMax[1]}/#{latMinMax[0]}/#{latMinMax[1]}")
#pp outputCSV.by_col['lon'].delete_at(0).minmax
#print outputCSV


returnAry = []
handle = File.open(inputFile).read.split("\n")

handle.each do |line|
	if /^([0-9]+)(.+)（(.+)）/.match(line)
		returnAry << [$3,$2]
	end
end
meisuiHash = returnAry.each_with_object(Hash.new {|v, k| v[k] = []}) {|mizu, hash|
	hash[mizu[0]] << mizu[1]
}

meisuiHash.each {|k,v|
puts k + ', ' + v.size.to_s
}