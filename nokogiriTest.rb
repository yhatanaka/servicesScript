require 'open-uri'
require 'nokogiri'
require "open_uri_redirections"
require 'pp'

url = 'http://karapaia.com/archives/52266809.html'
# allow https => http redirect
doc = Nokogiri::HTML(open(url, :allow_redirections => :all))

File.open('test.html', mode='w') do |f|
f.write(doc.inner_html)
end #f
#print doc.inner_html
exit

doc.at_css('#main').children.each do |aNode|
if aNode.name != 'text'
   pp aNode.name
   pp aNode
   puts "\n"
   end #if
end #each

