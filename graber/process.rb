#! usr/bin/ruby
#vi: set fileencoding=utf-8
# core lib
require 'net/http'
# gems
require 'open-uri'
require 'data_uri'
require 'nokogiri'
require 'css_parser'
require 'pry'
# local lib
require_relative 'parser'
require_relative 'download'
require_relative 'images'
require_relative 'arguments'
require_relative 'url'

module Graber
	class Process
        attr_accessor :images, :argument
        
        def initialize(url, path)
            @argument = Arguments.new(url, path)
            @argument.check
            @argument.normalize
            @images = Hash.new 
        end

        def parse
            parser = Parser.new(self.argument.url, self.argument.path)
            parser.css_file_searching_in_html
            self.images = parser.img_hash
        end

        def download
            Download.parallel(self.images, self.argument)
        end
	end
end

