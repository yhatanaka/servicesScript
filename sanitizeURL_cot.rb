#!/usr/bin/env ruby -Ku
#%%%{CotEditorXInput=Selection}%%%
#%%%{CotEditorXOutput=ReplaceSelection}%%%

require "pp"
require 'uri'
result = Array.new

#inputURL = File.read(ARGV.shift)
#inputURL = ARGV.shift

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

def removeRedirect(str)
	thisURI = URI.parse(str)
	host = thisURI.host
	newURL = ''
	thisURI = URI.parse(str)
	query = URI.decode_www_form(thisURI.query.to_s).to_h
	query.each {|idx,value|
		if /[\/a-zA-Z0-9\-\.]/.match(value) && /\//.match(value)
# URLのドメイン以下の部分、'/'で始まっていたら削除
			newURL = thisURI.scheme + '://' + thisURI.host + '/' + value.sub(/^\/?/, '')
		end
	}
	return newURL
end

#inputURLary = inputURL.split("\n")

#inputURLary.each do |f|
while $stdin.gets
	f = $_
	sanitizedURL = f
	sanitizedURL = url_http(URI.unescape(f))
	sanitizedURL = removeRedirect(sanitizedURL)
	sanitizedURL = removeDir(sanitizedURL)
	sanitizedURL = removeGetParam(sanitizedURL)
	sanitizedURL = removeCommaDigit(sanitizedURL)
	sanitizedURL = removeParam(sanitizedURL)
#	sanitizedURL = removeParam(removeCommaDigit(removeGetParam(sanitizedURL)))
	result.push(sanitizedURL.chomp)

end
puts result.uniq.sort.join("\n")