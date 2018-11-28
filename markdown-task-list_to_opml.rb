#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-
require 'rexml/document'

inputFile = ARGV.shift
ouputFile = ARGV.shift

opmlCore = '<?xml version="1.0" encoding="utf-8"?><opml version="1.0"><head><title>Untitled</title><expansionState></expansionState></head><body></body></opml>'
doc = REXML::Document.new(opmlCore)
entries = doc.get_elements("/opml/body").first

#exit
#(スペース or タブ)- [ (x)] なんとかかんとか
outline = /^([ \t]*)- \[([ xX])\] (.+)/

def addOutline(parentElement, outlineText, checkedFlag)
	newEntry = REXML::Element.new('outline')
#	newEntry = entries.add_element('outline', {'text' => formatTitle($1,$2,$3), 'sequence' => ''})
#	newEntry = entries.add_element('outline', {'text' => taskName})
	newEntry.add_attribute('text', outlineText)
	if checkedFlag
		newEntry.add_attribute('_status', 'checked')
	end #if
	parentElement.add_element(newEntry)
	return newEntry
end #def

aParentElement = entries
appendedElement = entries
previousIndentCount = 0
open(inputFile,'r') do |inFile|
	inFile.each do |line|
		line =~ outline
		indentCount = $1.count(" \t")
		taskDone = $2.downcase.eql?('x')
		taskName = $3
		if indentCount > previousIndentCount
			aParentElement = appendedElement
p indentCount.to_s + ' > ' + previousIndentCount.to_s
		elsif indentCount == previousIndentCount
			
		elsif indentCount < previousIndentCount
			aParentElement = aParentElement.parent
#puts aParentElement
		end #if
		appendedElement = addOutline(aParentElement, taskName, taskDone)
		previousIndentCount = indentCount
p indentCount
	end # inFile.each
end # do inFile

#puts doc
#exit

open(ouputFile,'w') do |outFile|
	outFile.print doc
end # do outFile
