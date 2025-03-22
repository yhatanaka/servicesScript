#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

# qgisで書き出したKMLファイルの<Placemark>に写真(<description>)を追加
# ruby addName2qgisKml.rb qgis.kml > newKml.kml

require 'rexml/document'
require 'rexml/xpath'
require 'pp'

inputFile = ARGV.shift
#inputFile = '/Users/hatanaka/Dropbox/qgis/2024-11-30_看板/2025-03-07.kml'

doc = REXML::Document.new(File.new(inputFile))

# fk_type ごとに Placemark の配列をハッシュに
# {fk_type1:[place1_1, place1_2,...] fk_type2:[place2_1, place2_2,...] ...}
placemarkTypeHash = doc.get_elements('//Placemark').each_with_object(Hash.new { |v, k| v[k] = []}) {|aPlacemark, hash|
	hash[aPlacemark.elements['ExtendedData/SchemaData/SimpleData[@name="fk_type"]'].text] << aPlacemark
}

format_kml = <<EOS
<?xml version='1.0' encoding='UTF-8'?> 
<kml xmlns='http://www.opengis.net/kml/2.2'>
	<Document/>
</kml>
EOS

doc = REXML::Document.new(format_kml)

placemarkTypeHash.each {|idx, ary|
# fk_type ごとにFolder
	aType = doc.root.elements['Document'].add_element('Folder')
	aType.add_element('name').add_text(idx)
# その中にポイント追加
	ary.each {|aPlace|
# 写真ファイル名(','連結)
		placemarkPhotoStr = aPlace.elements['ExtendedData/SchemaData/SimpleData[@name="photo"]']
		aPlace.delete_element('ExtendedData')
# 写真ファイル名があれば
		if placemarkPhotoStr
#','で区切る
			placemarkPhotoAry = placemarkPhotoStr.text.split(/, */).map{|n| '<img src="http://chokai-tobishima.net/2025-03-04_yuza/' + n + '">'}
			placemarkPhotoElement = aPlace.add_element('description')
			placemarkPhotoElement.add(REXML::CData.new(placemarkPhotoAry.join(''), true))
		end #if
		aType.add_element(aPlace)
	}
}
#pp placemarkTypeHash
print doc.to_s

exit

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
