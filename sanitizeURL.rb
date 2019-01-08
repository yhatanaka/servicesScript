#!/usr/bin/ruby
require "pp"
result = Array.new

inputURL = File.read(ARGV.shift)
#inputURL = ARGV.shift

def url_http(str)
	if (str.match(%r{.+(https?://.+)}))
		return $1
	else
		return str
	end
end

def removeGetParam(str)
	return str.gsub(/[&\?][a-z0-9]+=.*/, "")
end


inputURLary = inputURL.split("\n")

inputURLary.each do |f|

	sanitizedURL = removeGetParam(url_http(f))
	result.push(sanitizedURL)

end
puts result.uniq.sort.join("\n")