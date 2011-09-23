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
  require 'rubygems'
  require 'ted_api'
rescue => e
  $stderr.puts 'Unable to load modules. Please make sure that you have rubygems installed.'
  exit
end


