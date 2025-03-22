#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

# qgisで書き出したKMLファイルの<Placemark>に写真(<description>)を追加
# ruby addName2qgisKml.rb qgis.kml > newKml.kml

require 'rexml/document'
require 'rexml/xpath'
require 'pp'

#inputFile = ARGV.shift
inputFile = '/Users/hatanaka/Dropbox/qgis/2024-11-30_看板/export.kml'

doc = REXML::Document.new(File.new(inputFile))

doc.elements.each('//Placemark') do |placemark|
# 	placemarkName = placemark.elements['ExtendedData/SchemaData']
	placemarkPhotoStr = placemark.elements['ExtendedData/SchemaData/SimpleData[@name="photo"]']
#	placemark.delete_element('')
	if placemarkPhotoStr
		placemarkPhotoAry = placemarkPhotoStr.text.split(/, */).map{|n| '<img src="http://chokai-tobishima.net/2025-03-04_yuza/' + n + '">'}
		placemarkPhotoElement = placemark.add_element('description')
		placemarkPhotoElement.add(REXML::CData.new(placemarkPhotoAry.join(''), true))
	end #if
end

print doc.to_s

=begin

<Data name="gx_media_links">
<value><![CDATA[http://chokai-tobishima.net/2025-03-04_yuza/IMG_6907.jpeg http://chokai-tobishima.net/2025-03-04_yuza/IMG_6907.jpeg]]></value>
</Data>

=end
