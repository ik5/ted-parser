#!/usr/bin/env ruby

# This program downloads ted talks from the RSS feed.
# Version 0.1
#
#  Copyright (C) 2011  Ido Kanner
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

begin
  # try to add the file path as well to load ted_api
  $: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
  require 'ted_api'
  require 'rubygems'
  require 'optparse'
rescue LoadError => e
  $stderr.puts 'Unable to load modules. Please make sure that you have rubygems installed.'
  $stderr.puts "Exception: #{e.message}"
  $stderr.puts "Exception bt: #{e.backtrace.join("\n")}"
  exit
end

TED_VERSION = '0.1'
# Lets save the options here ...
$cli_options = {}

puts "ted.rb v#{TED_VERSION}.\n"
puts "Copyright (C) 2011 Ido Kanner.",
"License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.",
"This is free software: you are free to change and redistribute it.",
"There is NO WARRANTY, to the extent permitted by law.\n\n"

optparse = OptionParser.new do|opts|
  #opts.banner = 'Usage: ted.rb [options] ...'
  opts.on '-h', '--help', 'Display this help screen' do
    puts opts
    exit
  end

  opts.on '--version', 'Display current version and exit.' do
   puts "ted.rb v#{TED_VERSION}"
   exit
  end

  opts.on '-r', '--rss ADDRESS', 'Set different RSS address' do |address|
    $cli_options[:rss] = address
  end

  opts.on '-s', '--save PATH' , 'Set the path to save things at' do |path|
    $cli_options[:path] = path
  end

  opts.on '--force', 'Force download file even if already downloaded/exits.' do
    $cli_options[:force] = true
  end
end.parse!

# handle crashes and stuff needed to be done only when exiting
at_exit do
  #handle crashes - catch uncaught/handled exception.
  if $! 
    $stderr.puts "Uncought/handled exception: #{$!.message}"
    $stderr.puts "Backtrace of the exception: #{$!.backtrace.join("\n")}"
    puts 'Unclean exit.'
  end
end

