module Graber
    class Images
        attr_accessor :direct_link, :base64_encoded_uri, :link_encoded_uri, :img_name_by_counter, :data_uri, :img_scheme_and_host, :img_path, :img_name, :img_format  

        @@img_name_by_counter = 0
        #here we will save links to images in array
        def initialize(declarations, url_scheme)
			@link_encoded_uri    = Parser.link_encoded_uri_data?(declarations)
			@base64_encoded_uri  = Parser.base64_encoded_uri_data?(declarations)
			@direct_link         = Parser.direct_link?(declarations)
            @data_uri            = Parser.get_data_uri(declarations, self)

            @@img_name_by_counter==nil ? @@img_name_by_counter=0 : @@img_name_by_counter+=1

			if(@direct_link)
                @data_uri = URL.normalize_url_with_scheme_and_host(@data_uri, url_scheme)
                arr       = Parser.share_a_direct_link(@data_uri)
                if(arr)
                    @img_scheme_and_host = arr[0]
                    @img_path            = arr[1]
                    @img_name   = Parser.get_image_name(@img_path)
                    @img_format = Parser.get_img_format(@img_path, self)
                else
                    binding.pry
                end
            else
                @img_format = Parser.get_img_format(declarations, self)
                @img_name   = @@img_name_by_counter
		    end
        end

        def download(img_obj, arg_obj)
            if(img_obj.base64_encoded_uri)
                #it's a base64 encoded data uri
                decoded_uri = URI::Data.new(img_obj.data_uri)
                base64_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            elsif(img_obj.link_encoded_uri)
                #it's a link encoded data uri
                decoded_uri = URI.decode(img_obj.data_uri.split(',', 2)[1])
                link_encoded_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            elsif(img_obj.direct_link && img_obj.img_scheme_and_host && img_obj.img_path) 
                path = img_obj.img_scheme_and_host + img_obj.img_path
                direct_link_save_as_file(path, img_obj, arg_obj)
            end
        end
                
        def base64_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path) unless File.exists?(arg_obj.path)
            File.write(arg_obj.path+"/"+img_obj.img_name.to_s+"."+img_obj.img_format, decoded_uri.data)
            #@img_name_by_counter += 1
            p "base64 img saving"
        end

        def link_encoded_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path)unless File.exists?(arg_obj.path)
            File.write(arg_obj.path+"/"+img_obj.img_name.to_s+"."+img_obj.img_format, decoded_uri)#decoded_uri.data!!! maybe!!
            #@img_name_by_counter += 1
            p "url img saving"
        end

        def direct_link_save_as_file(path, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path)unless File.exists?(arg_obj.path)
            #if folder creation was successfuly, then
            # saving file from direct link
            @img_name = Parser.remove_dots_from_img_name(@img_name)
            File.open("#{arg_obj.path}/#{img_obj.img_name}.#{img_obj.img_format}", 'wb') {|file| 
                file.write(open(path).read)
            }
            p "direct link img saving"
        end
    end
end
