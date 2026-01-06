#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

require 'pp'

data = <<EOS
390000.0 1400000.0 390010.29902 1395947.81472 
391000.0 1400000.0 391010.23300 1395947.79790 
390000.0 1394500.0 390010.274 1394447.901
391000.0 1394500.0 391010.206 1394447.865
385000.0 1394500.0 385010.343 1394447.922
385000.0 1400000.0 385010.36390 1395947.84253
EOS

def ddmmss2digit(ddmmss)
	ddmmssDivByDotAry = ddmmss.split('.')
	ddmmssSize = ddmmssDivByDotAry[0].size
#ddmmss なら[-6..2]、dddmmss なら[-7..3]
	dd = ddmmssDivByDotAry[0][0,ddmmssSize-4]
	mm = ddmmssDivByDotAry[0][-4,2]
	ss = (ddmmssDivByDotAry[0][-2,2] + '.' + ddmmssDivByDotAry[1])
#	return [dd,mm,ss]
	return dd.to_i + mm.to_f/60 + ss.to_f/3600
end

dataAry = data.split(/\s*\n/)

dataAry.each {|dataRow|
	dataRowAry = dataRow.split(' ')
#	pp ddmmss2digit(dataRowAry[3])

	print ddmmss2digit(dataRowAry[2])
	print ','
	puts ddmmss2digit(dataRowAry[3])
}