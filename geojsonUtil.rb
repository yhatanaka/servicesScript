require 'json'
# GeoJSONを読み込む
def load_geojson(file_path)
	JSON.parse(File.read(file_path))
end

# lat, lng
def makeGeometry(featureType, coordinates)
# type: Point, coordinates: [lng, lat]
# type: LineString, coordinates: [ [lng, lat], [lng, lat], ...]
# type: Polygon, coordinates: [[ [lng, lat], [lng, lat], ...]]
	case featureType
	when 'Point'
		return {'type'=> featureType, 'coordinates' => coordinates}
		# return {'type'=> featureType, 'coordinates' => [coordinates[1], coordinates[0]]}
	when 'LineString'
		points = coordinates.map {|point|
			[point[1], point[0]]
		}
		return {'type'=> featureType, 'coordinates' => points}
	when 'Polygon'
		 points = coordinates.map {|point|
			[point[1], point[0]]
		}
		return {'type'=> featureType, 'coordinates' => [points]}
	else
		puts "nothing! #{type} #{coordinates}"
	end
	# {'type'=> type, 'coordinates' => }
end

# Feature
def makeFeature(featureType, coordinates, properties)
	geometry = makeGeometry(featureType, coordinates)
	return {'type' => 'Feature', 'geometry' => geometry, 'properties' => properties}
end

# FeatureCollection
def makeFeatureCollection(featuresAry)
	# case featuresAry.class
	# when 'Array'
	# 	features = featuresAry.map {|feature|
	# 		makeFeature(feature[0], feature[1])
	# 	}
	# when 'Hash'
		features = featuresAry.map {|feature|
			makeFeature(feature[:type], feature[:coordinates], feature[:properties])
		}
		return {'type' => 'FeatureCollection', 'features' => features}
	# else
	# 	puts "what's this? #{featuresAry.inspect}"
	# end
end

def booleanString2boolean(str)
	if str == 'TRUE' || 'true'
		return true
	elsif str == 'FALSE' || 'false'
		return false
	else
		return nil
	end
end
=begin
features = []
styles = {}

place.each do |placemark|
	geometry = extract_geometry(placemark)
	next unless geometry # ジオメトリがないPlacemarkはスキップ

	# KMLのnameとdescriptionを取得
	name = get_tag_text(placemark, 'name')
	description = get_tag_text(placemark, 'description')
	
	# 色情報を抽出
	color = extract_color(placemark, styles)
	
	# umap用のプロパティを作成
	properties = {}
	properties['name'] = name if name
	properties['description'] = description if description

	if color
		# umapに色を指定するための特別なプロパティ
		# 値はJSON文字列にする必要がある
		umap_options = { 'color' => color }
		# umap_options = { 'color' => color }.to_json
		properties['_umap_options'] = umap_options
		
		puts " -> Placemark: #{name || '名称なし'}, 色: #{color}"
	else
		puts " -> Placemark: #{name || '名称なし'}, 色: デフォルト (#000000)"
	end

	# GeoJSON Featureの構成
	feature = {
		'type' => 'Feature',
		'geometry' => geometry,
		'properties' => properties
	}
	features << feature
end

# GeoJSON FeatureCollectionの構成
geojson = {
	'type' => 'FeatureCollection',
	'features' => features
}

# GeoJSONをファイルに書き出し
File.open(GEOJSON_FILE, 'w') do |f|
	# 見やすいように整形して書き出す
	f.write(JSON.pretty_generate(geojson))
end

puts "\n処理が完了しました。"
puts "出力ファイル: #{GEOJSON_FILE}"
puts "Feature数: #{features.size}"



{
	"type": "FeatureCollection",
	"features": [
		{
			"type": "Feature",
			"geometry": {
				"type": "Point",
				"coordinates": [102.0, 0.5]
			},
			"properties": {
				"prop0": "value0"
			}
		},
		{
			"type": "Feature",
			"geometry": {
				"type": "LineString",
				"coordinates": [
					[102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
				]
			},
			"properties": {
				"prop0": "value0",
				"prop1": 0.0
			}
		},
		{
			"type": "Feature",
			"geometry": {
				"type": "Polygon",
				"coordinates": [
					[
						[100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
						[100.0, 1.0], [100.0, 0.0]
					]
				]
			},
			"properties": {
				"prop0": "value0",
				"prop1": { "this": "that" }
			}
		}
	]
}

=end