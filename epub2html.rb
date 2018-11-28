!#/usr/bin/ruby
require 'epub'
require 'pp'

epubFile = ARGV.shift
p epubFile
#aEpubDoc = Epub:initialize(epubFile)
#Epub::Epub.parse(epubFile)

class MyEpub
	extend Epub
end

myFirstEpub = MyEpub.new

print myFirstEpub
#p Module.constants

#p Module.nesting

#myFirstEpub.parse(epubFile)

#MyEpub.parse(epubFile)