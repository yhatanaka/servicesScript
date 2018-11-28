#!/bin/bash

/System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/ruby -w <<'EOF' - "$@"
# 
#   slim alias v0.33
#   written by Hiroto, 2014-09
# 

# 
#   ARGV = <file or directory> [<file or directory> ...]
# 
require 'cocoa'
include OSX

CLEAR_DATA_FORK = true  # true to clear data fork which may contain bookmark data, false otherwise.

while File.exist?(TEMPFILE = "/tmp/slim_alias.#{rand(1e6)}.r") do end
Signal.trap("EXIT") { File.delete TEMPFILE if File.exist? TEMPFILE }

def quoted_form(s)
    #   
    #   string s : source string
    #   return string : s's quoted form for use in shell
    #   * e.g., given s = a'b, quoted form of s = 'a'\''b'
    #   
    %q['%s'] % s.gsub(/'/) {%q['\'']}
end

def slim_alias1(f)
    #   
    #   string f : POSIX path of alias file
    #   * put 'alis' in resource fork, preserving data fork which may contain bookmark data
    #   
    f = quoted_form(f)
    %x[
exec 2>/dev/null
/usr/bin/derez -only 'alis' #{f} > "#{TEMPFILE}" ||         # derez 'alis' in resource fork
exit                                                        #   or exit
/usr/bin/rez -o #{f} -noResolve output "#{TEMPFILE}"        # put 'alis' in resource fork (overwrite resource fork)
    ]
end

def slim_alias2(f)
    #   
    #   string f : POSIX path of alias file
    #   * put 'alis' in resource fork, clear data fork and clear custom icon bit
    #   
    f = quoted_form(f)
    %x[
exec 2>/dev/null
/usr/bin/derez -only 'alis' #{f} > "#{TEMPFILE}" ||         # derez 'alis' in resource fork
exit                                                        #   or exit
/usr/bin/rez -o #{f} -noResolve output "#{TEMPFILE}" &&     # put 'alis' in resource fork (overwrite resource fork)
: > #{f}                                             &&     #   and clear data fork
/usr/bin/SetFile -a c #{f}                                  #   and clear custom icon bit
    ]
end

def scan_aliases(p)
    #   
    #   string p : absolute POSIX path of directory or file
    #   return array : aliases in directory tree rooted at p if p is directory; [p] if p is alias file; otherwise []
    #   
    aa = []
    ws = NSWorkspace.sharedWorkspace
    uti = ws.typeOfFile_error(p, nil)
    if uti == 'public.folder'
        de = NSFileManager.defaultManager.enumeratorAtPath(p)
        while (n = de.nextObject) != nil do
            f = p + '/' + n.to_s
            de.skipDescendants if ws.isFilePackageAtPath(f)     # ignore package contents
            if de.fileAttributes.objectForKey(NSFileType) == NSFileTypeRegular
                aa << f if ws.typeOfFile_error(f, nil) == 'com.apple.alias-file'
            end
        end
    elsif uti == 'com.apple.alias-file'
        aa << p
    end
    aa
end

def main(argv)
    # 
    #   array argv : array of every target file or directory where target tree is rooted at
    # 
    argv.map {|a| File.expand_path(a)}.each do |f|
        scan_aliases(f).each do |a|
            if CLEAR_DATA_FORK
                begin
                    # skip if data fork == 0 and resource fork <= 4096
                    next if File.size(a) == 0 && File.size(a + '/..namedfork/rsrc') <= 4096
                rescue
                end
                slim_alias2(a)
            else
                begin
                    # skip if resource fork <= 4096
                    next if File.size(a + '/..namedfork/rsrc') <= 4096
                rescue
                end
                slim_alias1(a)
            end
        end
    end
end

main(ARGV)
EOF