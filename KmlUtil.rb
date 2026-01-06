require 'rexml/document'
require 'rexml/xpath'
include REXML

# 読み込み
# KMLのaabbggrrカラーコードをGeoJSON/HTMLの#rrggbb形式に変換する
# KML: aa bb gg rr (透明度、青、緑、赤)
# HTML: # rr gg bb
def kml_color_to_html(kml_color)
	# aa(透明度)を無視し、bgrを抽出
	b = kml_color[2..3]
	g = kml_color[4..5]
	r = kml_color[6..7]
	
	"##{r}#{g}#{b}" # #rrggbb の形式で返す
rescue StandardError
	'#000000' # 失敗した場合は黒を返す
end

# REXML::Elementから特定のタグの値を取得
def get_tag_text(element, tag_name, namespace = nil)
	element.elements.each(tag_name) do |elem|
		# 名前空間が指定されている場合、要素のnamespaceが一致するかを確認
		if namespace.nil? || elem.namespace == namespace
			return elem.text
		end
	end
	nil
end

# GeoJSON Featureのジオメトリを抽出
def extract_geometry(placemark)
	geometry = nil
	type = nil
	coordinates = nil

	# Point
	if coords_tag = placemark.elements['Point/coordinates']
		coords = coords_tag.text.strip.split(',').map(&:to_f)
		# GeoJSONは[経度, 緯度]、KMLは[経度, 緯度, 高度]（高度は省略可）
		coordinates = [coords[0], coords[1]]
		type = 'Point'

	# LineString
	elsif coords_tag = placemark.elements['LineString/coordinates']
		# KMLの座標文字列（空白区切りで経度,緯度,高度）を [経度, 緯度] の配列の配列に変換
		coordinates = coords_tag.text.strip.split(/\s+/).map do |coord|
			c = coord.split(',').map(&:to_f)
			[c[0], c[1]]
		end
		type = 'LineString'

	# Polygon
	elsif boundary = placemark.elements['Polygon/outerBoundaryIs/LinearRing/coordinates']
		# KMLの座標文字列を [経度, 緯度] の配列の配列に変換
		coords_array = boundary.text.strip.split(/\s+/).map do |coord|
			c = coord.split(',').map(&:to_f)
			[c[0], c[1]]
		end
		# GeoJSON Polygonは [[リング座標1], [リング座標2], ...] の形式
		coordinates = [coords_array]
		type = 'Polygon'
	end

	# ジオメトリが存在する場合にハッシュとして返す
	if type && coordinates
		{
			'type' => type,
			'coordinates' => coordinates
		}
	else
		nil
	end
end

# KMLから色情報を抽出
def extract_color(placemark, styles)
	style_url = get_tag_text(placemark, 'styleUrl')
	style_id = get_tag_text(placemark, 'Style/@id')

	color_tag = nil
	
	# 1. Placemarkに直接Style要素がある場合
	if style_element = placemark.elements['Style']
		color_tag = get_tag_text(style_element, 'PolyStyle/color') || 
								get_tag_text(style_element, 'LineStyle/color') ||
								get_tag_text(style_element, 'IconStyle/color')
	end

	# 2. styleUrlで参照されるStyleMapまたはStyleがある場合
	if color_tag.nil? && style_url
		target_id = style_url.sub('#', '')
		
		if style_map = styles[target_id]
			# StyleMapの場合、通常は "normal" スタイルの参照を使用
			style_map.elements.each('Pair') do |pair|
				if get_tag_text(pair, 'key') == 'normal'
					normal_style_url = get_tag_text(pair, 'styleUrl')
					if normal_style_url
						target_id = normal_style_url.sub('#', '')
						break
					end
				end
			end
		end

		if style_element = styles[target_id]
			color_tag = get_tag_text(style_element, 'PolyStyle/color') || 
									get_tag_text(style_element, 'LineStyle/color') ||
									get_tag_text(style_element, 'IconStyle/color')
		end
	end

	if color_tag
		kml_color_to_html(color_tag)
	else
		nil # 色情報が見つからない
	end
end

# KMLからアイコンのhref (URL) を抽出
def extract_icon_url(placemark, styles)
	# 1. Placemarkに直接Style要素がある場合
	if style_element = placemark.elements['Style']
		if href = get_tag_text(style_element, 'IconStyle/Icon/href')
			return href
		end
	end

	# 2. styleUrlで参照されるStyleMapまたはStyleがある場合
	if style_url = get_tag_text(placemark, 'styleUrl')
		target_id = style_url.sub('#', '')
		
		# StyleMapの場合、通常は "normal" スタイルの参照を使用
		if style_map = styles[target_id]
			style_map.elements.each('Pair') do |pair|
				if get_tag_text(pair, 'key') == 'normal'
					normal_style_url = get_tag_text(pair, 'styleUrl')
					if normal_style_url
						target_id = normal_style_url.sub('#', '')
						break
					end
				end
			end
		end

		# Styleからhrefを取得
		if style_element = styles[target_id]
			if href = get_tag_text(style_element, 'IconStyle/Icon/href')
				return href
			end
		end
	end

	nil # アイコンURLが見つからない
end

# 書き込み
# KML座標文字列（lon,lat[,alt]）へ変換
def coords_to_kml(coords)
	if coords[0].is_a?(Array)
		coords.map { |c| coords_to_kml(c) }.join(' ')
	else
		coords.join(',')
	end
end

# Geometry を REXML で KML に変換
def geometry_to_kml(parent, geometry)
	type = geometry[:type]
	coords = geometry[:coordinates]
	option = geometry[:option]

	placemark = parent.add_element('Placemark')

	case type
	when 'Point'
		point = placemark.add_element('Point')
		point.add_element('coordinates').text = coords_to_kml(coords)
	when 'LineString'
		line = placemark.add_element('LineString')
		line.add_element('coordinates').text = coords_to_kml(coords)

	when 'Polygon'
		polygon = placemark.add_element('Polygon')
		outer = polygon.add_element('outerBoundaryIs')
		ring = outer.add_element('LinearRing')
		ring.add_element('coordinates').text = coords_to_kml(coords[0])

	else
		placemark.add_element('name').text = "Unsupported geometry type: #{type}"
	end
	
	if option
pp option
		option.each {|key, value|
			placemark.add_element(key).text = value
		}
	end
	# coords = "#{geometry[:lon]},#{geometry[:lat]}"
	# placemark = parent.add_element('Placemark')
	# sitename = REXML::Element.new('name')
	# sitename.add_text(geometry[:name])
	# placemark.add_element(sitename)
	# point = placemark.add_element('Point')
	# point.add_element('coordinates').text = coords
end

# GeoJSON → KML 全体構築
def make_kml(geojson_data)
	doc = Document.new
	doc << XMLDecl.new('1.0', 'UTF-8')

	kml = doc.add_element('kml', { 'xmlns' => 'http://www.opengis.net/kml/2.2' })
	document = kml.add_element('Document')

	# geojson_data['features'].each do |feature|
	# 	geometry = feature['geometry']
	# 	geometry_to_kml(document, geometry)
	# end

	doc
end


=begin
outputArray.each do |aGeosite|
	placemark = REXML::Element.new('Placemark')

	sitename = REXML::Element.new('name')
	sitename.add_text(aGeosite[0])
	placemark.add_element(sitename)

	point = REXML::Element.new('Point')
	coordinates = REXML::Element.new('coordinates')
	coordinates.add_text(aGeosite[1].join(','))
	point.add_element(coordinates)
	placemark.add_element(point)

	styleUrl = REXML::Element.new('styleUrl')
	styleUrl.add_text('#icon-1899-FFEA00-nodesc')
#	styleUrl.add_text('#icon-503-DB4436-nodesc')
#	styleUrl.add_text('#icon-503-DB4436-nodesc')
#p styleUrl.text
	placemark.add_element(styleUrl)
p placemark.elements['styleUrl'].text
	doc.root.elements['Document'].add_element(placemark)
end #each


format_kml = <<EOS
<?xml version='1.0' encoding='UTF-8'?> 
<kml xmlns='http://www.opengis.net/kml/2.2'>
	<Document>
		<name></name>
	</Document>
</kml>
EOS

=end