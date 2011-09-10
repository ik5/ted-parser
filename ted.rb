#!/usr/bin/env ruby

# This program downloads ted lectures from the RSS feed.
# Version 0.1
#
#  Copyright (C) 2011  Ido Kanner
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

begin
  require 'rubygems'
  require 'rss/1.0'
  require 'rss/2.0'
  require 'open-uri'
rescue
  $stderr.puts 'Unable to load modules. Please make sure that you have rubygems installed.'
  exit
end

RSS_ADDRESS = 'http://feeds.feedburner.com/tedtalks_video'


module TedAPI
  class API
   def initialize(address = RSS_ADDRESS)
     @address = address
   end 
   
   # parsed_xml return parsed RSS content into ruby structure
   #
   # Params:
   # address - is the rss address for TED.com Default is RSS_ADDRESS
   #
   # Return:
   #  The parsed rss or nil, if exception was raised
   #
   def parsed_xml
     content = open(@address).read
     @rss = RSS::Parser.parse(content, false)
   rescue => e
     $stderr.puts "Unable to parse RSS: #{e.message}"
     nil
   end

   # 
   #
   #
   #
   #
   def get_urls
    # TODO 
   end  
 
   # download return the content of a file
   #
   # Params:
   #  url - The url to download from
   #  type - The type of file to download:
   #           :highres    - The high resulotion vido (default)
   #           :desktopmp4 - The desktop version video 
   #           :desktopmp3 - The desktop version audio only
   #           :lowres     - The low resulotion video
   # Note:
   #  iTunes not supported at the moment
   #
   # Returns:
   #   Content of the file, or nil if error
   #
   def download(url, type = :highres)
     # TODO
   end
   
   # 
   def save(content, path)
    # TODO
   end
   
   #
   def exec(rss)
    # TODO
   end
   
   def remember_download(url, type = :highres)
    # TODO
   end

  end
end


