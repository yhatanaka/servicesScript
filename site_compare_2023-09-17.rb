# -*- coding: utf-8 -*-
$KCODE='UTF8'
Encoding.default_external = "UTF-8"
# Encoding.default_internal = "UTF-8"

require 'pp'
require 'csv'
oldFile = ARGV.shift
newFile = ARGV.shift

oldSite = CSV.read(oldFile, headers: true)
newSite = CSV.read(newFile, headers: true)

resultCSV = CSV::generate_line(newSite.headers)

siteAry = oldSite.by_col['サイト名']
newSite.each do |aSite|
	unless siteAry.include?(aSite['name'])
		resultCSV << CSV::generate_line(aSite)
	end
end
print resultCSV

exit

resultCSV = CSV::generate_line(['name', 'area', 'site_type'])

resultCSV << CSV::generate_line(lineAry)

print resultCSV
