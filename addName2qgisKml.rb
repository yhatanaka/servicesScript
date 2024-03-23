#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

# qgisで書き出したKMLファイルの<Placemark>に<name>を追加
# ruby addName2qgisKml.rb qgis.kml > newKml.kml

require 'rexml/document'
require 'rexml/xpath'
require 'pp'

inputFile = ARGV.shift

doc = REXML::Document.new(File.new(inputFile))

doc.elements.each('//Placemark') do |placemark|
# 	placemarkName = placemark.elements['ExtendedData/SchemaData']
	placemarkName = placemark.elements['ExtendedData/SchemaData/SimpleData[@name="サイト名"]']
# 	pp placemarkName.text
	placemarkNameElement = placemark.add_element('name')
	placemarkNameElement.add_text(placemarkName.text)
end

print doc.to_s