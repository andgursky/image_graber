
module Graber
	class Parser 
        STYLE_TAG_HASH = {"link[rel='stylesheet']"=>"href", "style"=>nil} 
        IMG_TAG_LIST   = ["a", "span", "img", "i", "meta"]
        IMG_TAG_PARAMS = {"a"=>"style", "span"=>"style", "img"=>"src", "i"=>"style", "link"=>"href",
        "meta"=>"content"}
        AGENT          = {"User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0,2490.80 Safari/537.36"}

        attr_accessor :url, :img_folder, :img_hash 

		def initialize(url, img_folder)
            begin
                @arg_url    = url
                #@url        = open_url
                #@html       = Nokogiri::HTML(@url)
                @url_scheme = URI::split(url)
            rescue RuntimeError  => e
                url = URL.redirections_scheme(url)
                retry
            end
            @img_folder = img_folder
            @img_hash   = Hash.new
            @img_obj_counter = 0
		end

        def css_file_searching_in_html
            STYLE_TAG_HASH.each {|style_tag, style_atr|
                size = @html.css(style_tag).size
                @html.search(style_tag).map {|l|
                    if style_atr
                        #if styles is in css file
                        css_url = l[style_atr] 
                        css_url = URL.normalize_url_with_scheme_and_host(css_url, @url_scheme) 
                        css     = CssParser::Parser.new
                        begin
                            css.load_uri!(css_url)
                        rescue
                            p "I couldn't read #{css_url} file for some reason"
                        end
                        img_searching_in_css_file(css, @url_scheme)
                    else
                        #if styles is between <style></style> tags
                        css_block = l.text
                        css = CssParser::Parser.new
                        begin
                            css.add_block!(css_block)
                        rescue
                            p "I couldn't read #{css_block} file for some reason"
                        end
                        img_searching_in_css_file(css, @url_scheme)
                    end
                }
            }
		end

        def img_searching_in_html
            IMG_TAG_LIST.each {|tag_l|
                IMG_TAG_PARAMS.each_pair{|tag_p, atr|
                    @html.search(tag_l).map {|l|
                        unless tag_l==tag_p
                            l.search(tag_p).each {|img|
                                img_url = img[atr]
                                #I have to invent func that could determine is this url an image or not
                                image = Images.new(img_url, @url_scheme)
                                if Parser.direct_link?(image.data_uri)#may be this is not a direct link
                                  add_img_to_hash(image)
                                end
                            }
                        else
                            img_url = l[atr] 
                            if img_url
                               image = Images.new(img_url, @url_scheme)
                               if Parser.direct_link?(image.data_uri)
                                  add_img_to_hash(image)
                               end
                            end
                        end
                    }
                }
            }
        end
        
        def img_searching_in_css_file(css, url_scheme)
            css.each_selector do |selector, declarations, specificity|
                if(right_declarations?(declarations))
                  image = Images.new(declarations, url_scheme)
                  add_img_to_hash(image)
                end
            end	
        end

        def add_img_to_hash(img_obj)
            @img_hash[img_obj.data_uri] = img_obj
        end

        def right_declarations?(declarations)
            /background.*url\(/ =~ declarations ? true : false
        end

		def self.get_data_uri(declarations, img_obj)
		#	pattern = /\([^()]*?\)/
		#	declaration.gsub(pattern) {|x| return x[1..-2]}
            case 
            when img_obj.base64_encoded_uri 
                declarations.gsub(/[\(|\"|\']data:image\/[^()]+(?=\"|\)|\')/){|x| 
                    return x[1..-2]} 
            when img_obj.direct_link
                declarations.gsub(/(?<=\(\"|\(\'|\()[^\"\'\(\)]+(?=\"\)|\'\)|\))/){|x| 
                    return x[0..-1]}
            when img_obj.link_encoded_uri
                declarations.gsub(/\"[^"]+\"/){|x|
                    return x[1..-2]}
            end
		end

		def self.link_encoded_uri_data?(declarations)
			#if starts with words "data:image/svg+xml;charset=utf8"
			pattern = /\;[charset=utf8]+\,/
			return pattern =~ declarations ? true : false
        end

		def self.base64_encoded_uri_data?(declarations)
                
			#if starts with words "data:image/png;base64,"
			pattern = /\;[\w]+\,/
			return pattern =~ declarations ? true : false
		end

		def self.direct_link?(declarations)
			#if ends with .png .jpg .bmp ,svg ,gif and so on
			pattern1 = /url[\(|\(\'|\("]+[htt(p|ps):|\/\/]+.*\.(?=[#{Images::IMAGE_EXTENCIONS.join("|")}]+[\)|\(\'|\"\)]+)/
            pattern2 = /(htt(p|ps):|\/).*\.(?=[#{Images::IMAGE_EXTENCIONS.join("|")}]+$)/
			if(pattern1 =~ declarations || pattern2 =~ declarations)
                return true 
            else
                return false
            end
		end
		
		def get_correct_host(host)
			return URL.normalize(host)
		end

        def self.get_img_format(path, img_obj)
			#returns image format (.jpg .bmp .svg .png and so on)
            case 
            when img_obj.direct_link 
                pattern = /\.[\w\d]*$/ 
                path.gsub(pattern) {|x| return x[1..-1]}
            when img_obj.base64_encoded_uri || img_obj.link_encoded_uri
                img_format_pattern = /image\/[\w]+[\D\W]/
                path.gsub(img_format_pattern){|x| return x[6..-2]}  
            end
        end

        def self.remove_dots_from_img_name(img_name)
            name = img_name.gsub(/\.|@/, '_')
            return name
        end

        def self.shorten_the_name_if_needed(name)
            max_lenght = 255 / 4 
            if(name.size>max_lenght)
                return name[-max_lenght, max_lenght]
            else
                return name
            end
        end

		def self.get_image_name(path)
			#returns image name
			pattern = /\/[^\/]+(?=\.[\w\d]+)/ 
			path.gsub(pattern){|x|
              return x[1..-1]
            }
		end

		def self.share_a_direct_link(link)
			#it should split link on host and path
			#arr[0] - img_scheme_and_host
			#arr[1] - img_path
			uri = URI(link)	
            if(uri.scheme && uri.host)
                arr = []
                if(!uri.scheme) #scheme = nil
                    arr[0] = get_correct_host(uri.host)
                elsif(uri.scheme)
                    arr[0] = uri.scheme + "://" + uri.host
                end

                arr[1] = uri.path
                return arr
            else
                puts "uri.schmee or uri.host == nil"
            end
        end

        def open_url
            open(@arg_url, AGENT)
        end

        def get_content
            @html = Nokogiri::HTML(self.open_url)
        end
    end
end 
