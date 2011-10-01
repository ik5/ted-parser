#!/usr/bin/env ruby

# API module and class to use 
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

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'json'

RSS_ADDRESS      = 'http://feeds.feedburner.com/tedtalks_video'
CONFIG_PATH      = '~/.config/tedrb/'
DOWNLOADED_FILE  = 'downloaded.json'


module TedAPI

  class ParserAPI
   def initialize(address = RSS_ADDRESS)
     @address = address
     parsed_xml
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
     puts 'At parsed_xml' if TedAPI::debug
     @rss = RSS::Parser.parse(open(@address), false)
   rescue => e
     $stderr.puts "Unable to parse RSS: #{e.message}"
     nil
   ensure 
     puts 'done parsed_xml' if TedAPI::debug
   end

   # get_urls parse the rss and return only the urls to be used 
   #
   # Return:
   #   arrays with url's
   #   Or nil if something is wrong
   #
   def get_urls
     puts 'at get_urls' if TedAPI::debug
     return nil unless @rss 
     
     result = []

     @rss.channel.items.each do |item| 
       puts "saving [#{item}] into array" if TedAPI::debug
       result << item.enclosure.url
     end

     # make sure we return result and not rss ...
     result
   rescue => e
     $stderr.puts "Unable to retrive urls: #{e.message}"
     nil
   ensure 
     puts 'Done get_urls' if TedAPI::debug
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
     puts 'at get_url_by_type' if TedAPI::debug
     # select what extension to provide 
     types = { :desktopmp4 => '',          :desktopmp3 => '.mp3', 
               :highres    => '-480p.mp4', :lowres     => '-light.mp4'
             }

     puts "url : [#{url}], type : [#{type}]" if TedAPI::debug
     return '' unless types.key? type
     ext = types[type] 
     # set the next extention without removing the content of url
     newurl = url                         if ext.empty?
     newurl = url.gsub(/\.mp4$/, ext) unless ext.empty?
     puts "newurl : [#{newurl}]" if TedAPI::debug
     
     newurl
   ensure
     puts 'Done get_url_by_type' if TedAPI::debug
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
     puts 'at download' if TedAPI::debug
     puts "url [#{url}], path [#{path}], type [#{type}]" if TedAPI::debug
     # TODO - security checks for path

     newurl = get_url_by_type(url, type)
     return false if newurl.empty?

     # start parsing the url ...
     require 'uri'
     uri   = URI::parse(newurl)
     fname = File.basename(newurl) # save the file name ...
     puts "uri: [#{uri.inspect}], fname : [#{fname}]" if TedAPI::debug
     FileUtils.mkdir_p(path) unless File.exist?(path) # create the path ...

     # let's download the content and save it to a file
     require 'net/http'
     Net::HTTP.start(uri.host) do |http|
       answer = http.get(uri.path)
       open(path + fname, 'wb') do |f|
         write(answer.body)
       end
     end

     puts "answer : [#{answer}], file exists ? [#{File.exists?(path + fname)}]" if TedAPI::debug

     # should return true or false
     (answer == 200) && (File.exists?(path + fname))
   rescue => e
     $stderr.puts "Unable to download file: #{e.message}"
     false
   ensure
     puts 'Done download' if TedAPI::debug
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
   # Note: 
   #   The method does not return any value 
   #
   def remember_download(url, type = :highres)
     puts 'at remember_download' if TedAPI::debug
     puts "url: [#{url}], type: [#{type}]" if TedAPI::debug
     # First we make sure that we have the config directory ...
     # TODO: Add security checks for path and file
     path = File.expand_path CONFIG_PATH
     FileUtils.mkdir_p(path) unless File.exist?(path)

     if File.exists?(path + DOWNLOADED_FILE)
       puts 'Reading json file' if TedAPI::debug
       json = JSON::parse(open(path + DOWNLOADED_FILE).read) 
       puts "json content:\n\t#{json}" if TedAPI::debug
     else
       puts 'No json file to read' if TedAPI::debug
       json = {'download' => [], 'orig' => []}
     end

     newurl = get_url_by_type(url, type)
     puts "newurl : [#{newurl}]" if TedAPI::debug
     json['download'] << [{'url' => newurl, 'type' => type}]
     json['orig']     << [{'url' => url,    'type' => type}]

     json['lastdl'] = Time.now
     open(path + DOWNLOADED_FILE, 'w') do |f|
       f.write(json.to_json)
     end

     nil
   rescue => e
     $stderr.puts "Unable to remember download: #{e.message}"
     nil
   ensure
     puts 'done remember_download' if TedAPI::debug
   end

   # Check to see if the given url and type exists
   #
   # Parameters:
   #   url  - The url that was sent to download
   #   type - The type of download to be made
   #           :highres    - The high resulotion vido (default)
   #           :desktopmp4 - The desktop version video 
   #           :desktopmp3 - The desktop version audio only
   #           :lowres     - The low resulotion video
   #
   # Return:
   #   true if the url and type was found
   #   false if the url and type was not found
   #
   def downloaded?(url, type = :highres)
     puts 'at downloaded?' if TedAPI::debug
     puts "url : [#{url}], type : [#{type}]" if TedAPI::debug
     # Check to see if the download json file exists 
     fdownload = File.expand_path(CONFIG_PATH) + DOWNLOADED_FILE
     puts "fdownload [#{fdownload}]" if TedAPI::debug
     return false unless File.exists? fdownload
     
     newurl = get_url_by_type(url, type)
     puts "newurl : [#{newurl}]" if TedAPI::debug
     json = JSON::parse(open(fdownload).read)
     puts "json :\n\t#{json}" if TedAPI::debug

     json['download'].include?({'url' => newurl, 'type' => type})
   rescue => e
     $stderr.puts "Unable to read downloaded file: #{e.message}"
     false
   ensure
     puts 'done downloaded?' if TedAPI::debug
   end

  end # class ParserAPI
end # module TedAPI


