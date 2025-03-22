Encoding.default_external = "UTF-8"

require 'pp'
handle = File.open(ARGV.shift).read.split("\n")

handle.each do |line|
	lineAry = []
	if /^((  )+)(- .+)/.match(line)
# 次の正規表現のヒットで$1〜が変化するので、その前に変数に入れておく
		reading = $1
		content = $3
		puts reading.gsub(/  /, "\t") + content
	else
		puts line
	end #if
end #each
