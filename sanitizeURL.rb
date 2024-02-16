#!/usr/bin/ruby
require "pp"
require 'uri'
result = Array.new

#inputURL = File.read(ARGV.shift)
inputURL = ARGV.shift

def url_http(str)
	if (str.match(%r{.+(https?://.+)}))
		return $1
	else
		return str
	end
end

def removeDir(str)
	return str.sub(/\/[a-zA-Z0-9_]+\.[a-zA-Z]+\?[a-zA-Z]+\=/, "")

end

def removeGetParam(str)
	return str.gsub(/[&\?][a-z0-9]+=.*/, "")
end

def removeCommaDigit(str)
	return str.sub(/\/?,[0-9,\-]+/,"")
end

def removeParam(str)
	return str.sub(/html\?.+$/,"html")
end


inputURLary = inputURL.split("\n")

inputURLary.each do |f|
	sanitizedURL = url_http(URI.unescape(f))
	sanitizedURL = removeDir(sanitizedURL)
	sanitizedURL = removeParam(removeCommaDigit(removeGetParam(sanitizedURL)))
	result.push(sanitizedURL)

end
puts result.uniq.sort.join("\n")