
module Graber
	class Parser 
        attr_accessor :url, :img_folder, :img_hash
        
		def initialize(url, img_folder)
            @url        = open(url) 
            @url_scheme = URI::split(url)
            @img_folder = img_folder
            @img_hash   = Hash.new
            @img_obj_counter = 0
		end

		def css_file_searching_in_html
			html = Nokogiri::HTML(@url)
			html.search("link[rel='stylesheet']").map {|l|
				css_url    = l['href'] 
                css_url    = URL.normalize_url_with_scheme_and_host(css_url, @url_scheme) 
                css        = CssParser::Parser.new
                begin
                    css.load_uri!(css_url)
                rescue
                    p "I couldn't read #{css_url} file for some reason"
                end
                img_searching_in_css_file(css, @url_scheme)
			}
		end
        
        def img_searching_in_css_file(css, url_scheme)
            css.each_selector do |selector, declarations, specificity|
                
                if(right_declarations?(declarations))
                  image = Images.new(declarations, url_scheme)
                  @img_hash[@img_obj_counter] = image
                  @img_obj_counter += 1 
                end
            end	
            binding.pry
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
            #img_format_pattern = /image\/[\w]+[\D\W]/
            #declarations.gsub(img_format_pattern){|x| @img_format = (5..-2)}  
			return pattern =~ declarations ? true : false
        end

		def self.base64_encoded_uri_data?(declarations)
			#if starts with words "data:image/png;base64,"
			pattern = /\;[\w]+\,/
            #img_format_pattern = /image\/[\w]+[\D\W]/
            #declarations.gsub(img_format_pattern){|x| @img_format = (5..-2)}  
			return pattern =~ declarations ? true : false
		end


		def self.direct_link?(declarations)
			#if ends with .png .jpg .bmp ,svg ,gif and so on
			pattern = /url[\(|\(\'|\("]+[http:|\/\/]+/
			return pattern =~ declarations ? true : false
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

        def self.remove_dots_from_img_name(img_name)# use before saving
            return img_name.gsub(/\.|@/, '_') #I think I need to remove not only dots, but '@' too
        end

		def self.get_image_name(path)
			#returns image name
			pattern = /\/[^\/]+(?=\.[\w\d]+)/ 
			path.gsub(pattern){|x|
                return x[1..-1]}
		end

		def self.share_a_direct_link(link)
			#it should split link on host and path
			#arr[0] - img_scheme_and_host
			#arr[1] - img_path
            puts link
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
                binding.pry
            end
        end
    end
end 
