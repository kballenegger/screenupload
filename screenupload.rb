#!/usr/bin/env ruby


require 'rubygems'
require 'bundler/setup'
require 'terminal-notifier'
require 'cgi'

require 'rb-fsevent'

last_check = Time.now

fsevent = FSEvent.new
fsevent.watch(File.expand_path('~/Desktop')) do |directories|
  previous_check = last_check; last_check = Time.now
  directories.each do |d|
    d = File.expand_path(d)
    next unless d == File.expand_path('~/Desktop')

    Dir["#{d}/*"]
      .select {|f| File.mtime(f) > previous_check }
      .select {|f| f =~ /Screen Shot [0-9]{4}-[0-9]{2}-[0-9]{2} at [0-9]{2}\.[0-9]{2}\.[0-9]{2} (AM|PM)\.(png|jpg|tiff)$/ }
      .sort {|a,b| File.mtime(b) <=> File.mtime(a) }
      .each do |f|
        fn = f.split('/').last
        puts "Found new screenshot: #{fn}"
        system("scp '#{f}' 'azure:/home/kenneth/www/akhun.com/public/seo/skitch/#{fn.gsub(' ', '\ ')}'")
        system("mv '#{f}' '#{File.expand_path('~/.Trash/')}/'")
        system("echo 'http://akhun.com/seo/skitch/#{CGI.escape(fn).gsub('+', '%20')}' | pbcopy")
        TerminalNotifier.notify("Copied URL for #{fn} to clipboard.", :title => 'Screenshot Uploader')
    end
  end
end
fsevent.run

