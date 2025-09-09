require 'json'
require 'rexml/document'
include REXML

# GeoJSONを読み込む
def load_geojson(file_path)
  JSON.parse(File.read(file_path))
end

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
  type = geometry['type']
  coords = geometry['coordinates']

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
end

# GeoJSON → KML 全体構築
def convert_geojson_to_kml(geojson_data)
  doc = Document.new
  doc << XMLDecl.new('1.0', 'UTF-8')

  kml = doc.add_element('kml', { 'xmlns' => 'http://www.opengis.net/kml/2.2' })
  document = kml.add_element('Document')

  geojson_data['features'].each do |feature|
    geometry = feature['geometry']
    geometry_to_kml(document, geometry)
  end

  doc
end

# メイン処理
if ARGV.length < 2
  puts "使い方: ruby geojson_to_kml_rexml.rb input.geojson output.kml"
  exit
end

input_file = ARGV[0]
output_file = ARGV[1]

geojson = load_geojson(input_file)
kml_doc = convert_geojson_to_kml(geojson)

File.open(output_file, 'w') do |file|
  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true
  formatter.write(kml_doc, file)
end

puts "KMLファイルを出力しました: #{output_file}"