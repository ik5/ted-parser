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
     @rss = RSS::Parser.parse(open(@address), false)
   rescue => e
     $stderr.puts "Unable to parse RSS: #{e.message}"
     nil
   end

   # get_urls parse the rss and return only the urls to be used 
   #
   # Return:
   #   arrays with url's
   #   Or nil if something is wrong
   #
   def get_urls
     return nil unless @rss 
     
     result = []

     @rss.channel.items.each do |item| 
       result << item.enclosure.url
     end

     # make sure we return result and not rss ...
     result
   rescue => e
     $stderr.puts "Unable to get titles and urls: #{e.message}"
     nil
   end  

   # Change url according to the type
   #
   # Parameters:
   #   url  - The original url that was given   
   #   type - The file type to download
   #           :highres    - The high resulotion vido (default)
   #           :desktopmp4 - The desktop version video 
   #           :desktopmp3 - The desktop version audio only
   #           :lowres     - The low resulotion video
   #
   # Return :
   #   The new url if the type was known
   #   empty string if type was unknown
   #
   def get_url_by_type(url, type)
     # select what extension to provide 
     types = { :desktopmp4 => '',          :desktopmp3 => '.mp3', 
               :highres    => '-480p.mp4', :lowres     => '-light.mp4'
             }

     return '' unless types.key? type
     ext = types[type] 
     # set the next extention without removing the content of url
     newurl = url                         if ext.empty?
     newurl = url.gsub(/\.mp4$/, ext) unless ext.empty?
     
     newurl
   end

   # download return the content of a file
   #
   # Params:
   #  url  - The url to download from
   #  path - The path (without file name) to save the content 
   #  type - The type of file to download:
   #           :highres    - The high resulotion vido (default)
   #           :desktopmp4 - The desktop version video 
   #           :desktopmp3 - The desktop version audio only
   #           :lowres     - The low resulotion video
   # Note:
   #  iTunes not supported at the moment
   #
   # Returns:
   #   true if successful, or false if not
   #
   def download(url, path, type = :highres)
     # TODO - security checks for path

     newurl = get_url_by_type(url, type)
     return false if newurl.empty?

     # start parsing the url ...
     require 'uri'
     uri   = URI::parse(newurl)
     fname = File.basename(newurl) # save the file name ...

     # let's download the content and save it to a file
     require 'net/http'
     Net::HTTP.start(uri.host) do |http|
       answer = http.get(uri.path)
       open(path + fname, 'wb') do |f|
         write(answer.body)
       end
     end

     # should return true or false
     (answer == 200) && (File.exists?(path + fname))
   rescue => e
     $stderr.puts "Unable to download file: #{e.message}"
     false
   end
  
   # Save the information about the downloaded content
   # Allowing to skip redownloading it again.
   #
   # Parameters:
   #   url  - The url that was sent to download
   #   type - The type of download to be made
   #           :highres    - The high resulotion vido (default)
   #           :desktopmp4 - The desktop version video 
   #           :desktopmp3 - The desktop version audio only
   #           :lowres     - The low resulotion video
  #
   def remember_download(url, type = :highres)
    # TODO
   end

   #
   def downloaded?(url)
     # TODO
   end

   #
   def exec(rss)
    # TODO
   end

  end # class API
end # module TedAPI


