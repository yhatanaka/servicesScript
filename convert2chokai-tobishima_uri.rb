#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

# require 'CGI'
require 'pp'

hostUri = 'http://chokai-tobishima.net'
# replaceString = 'file:///Users/hatanaka/Dropbox/ジオパーク'
# replaceString = 'file:///Users/hatanaka/Dropbox/ジオパーク/chokai-tobishima'
replaceString = /file:.+chokai-tobishima/

ARGV.each do |f|
    localUri = +f
    remoteUriDirectory = localUri.force_encoding("UTF-8").sub(replaceString, hostUri)
    puts remoteUriDirectory
end
exit

# localUri = 'file:///Users/hatanaka/Dropbox/%E3%82%B7%E3%82%99%E3%82%AA%E3%83%8F%E3%82%9A%E3%83%BC%E3%82%AF/chokai-tobishima/2022-11-23_koeki-univ/index.html'


=begin
def encode_ja(url)
  ret = ""
  url.split(//).each do |c|
    if  /[-_.!~*()a-zA-Z0-9;\/\?:@&=+$,%#]/ =~ c
      ret.concat(c)
    else
      ret.concat(CGI.escape(c))
    end
  end
  return ret
end

=end
# pp encode_ja('file:///Users/hatanaka/Dropbox/ジオパーク')