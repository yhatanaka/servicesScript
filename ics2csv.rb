#!/usr/bin/ruby

# iCalendar のファイル (*.ics) をパースして表示する

require 'rubygems'
require 'icalendar'
require 'date'
require 'pp'
require 'csv'


def dateFormatFunc(aDate)
	return aDate.strftime("%Y-%m-%d %H:%M:%S")
end

headerArray = ['Start Date','End Date','Event Title']
outputArray = Array.new
outputCSVString = CSV::generate_line(headerArray)
#outputCSVString = ''

files = ARGV
files.each {|filename|
	ics = File.open(filename)
	cals = Icalendar::Calendar.parse(ics)
	ics.close
	events = cals.first.events
# events = cals.first.events.sort {|a, b|
# 	a.dtstart <=> b.dtstart
# }

	events.each { |aEvent|
		next if aEvent.dtend < Date.today
#		outputCSVString << CSV::generate_line([dateFormatFunc(aEvent.dtstart),dateFormatFunc(aEvent.dtend),aEvent.summary])
#		outputArray << aEvent
#		outputArray << [aEvent.dtstart,aEvent.dtend,aEvent.summary]
		outputArray << [dateFormatFunc(aEvent.dtstart),dateFormatFunc(aEvent.dtend),aEvent.summary]
#		pp aEvent.dtstart
	#	pp aEvent.dtstart.ical_params['tzid']
#		pp aEvent.summary
	}
#	pp events.count
}

outputArray.uniq!

outputArray.sort! {|a,b|
	Date.parse(a[0]) <=> Date.parse(b[0])
}
outputArray.uniq!

outputArray.each { |outputEvent|
	outputCSVString << CSV::generate_line(outputEvent)
}
print outputCSVString.split("\n").uniq!.join("\n")
#print outputCSVString

#  print event.dtstart.strftime("%F %T")
# sudo gem install icalendar
# unique
# label