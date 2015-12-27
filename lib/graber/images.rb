module Graber
    class Images
        attr_accessor :direct_link, :base64_encoded_uri, :link_encoded_uri, :img_name_by_counter, :data_uri, :img_scheme_and_host, :img_path, :img_name, :img_format, :negative_counter  

        @@img_name_by_counter  = 0
        IMAGE_EXTENCIONS = ["jpg", "jpeg", "png", "bmp", "ico", "gif", "svg", "webp"]

        #here we will save links to img_objs in array
        def initialize(declarations, url_scheme)
            @negative_counter    = 0
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
                    @img_name = Parser.remove_dots_from_img_name(Parser.get_image_name(@img_path))
                    @img_format = Parser.get_img_format(@img_path, self)
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
                @www_flag = 0
                begin
                    direct_link_save_as_file(path, img_obj, arg_obj)
                rescue OpenURI::HTTPError => e
                    if(@www_flag==0)
                        img_obj.data_uri            = URL.add_www_to_url(img_obj.data_uri)
                        img_obj.img_scheme_and_host = URL.add_www_to_url(img_obj.img_scheme_and_host)
                        path                        = URL.add_www_to_url(path)
                        @www_flag=1
                        retry
                    else
                        responce = e.io
                        puts "!!!ATTENTION!!! file: '#{img_obj.data_uri}' couldn't be downloaded by reason: '#{responce.status.join(' ')}'"
                    @negative_counter += 1
                    end
                case responce.status[0].to_i
                when 400..600
                    #delete empty img file from the folder
                    res = remove_file("#{arg_obj.path}/#{img_obj.img_name.to_s}.#{img_obj.img_format}")
                end
                rescue Errno::ENAMETOOLONG => e
                    # Shorten the string
                    img_obj.img_name = Parser.shorten_the_name_if_needed(img_obj.img_name)
                    retry
                rescue Exception => e
                    puts "==> File: '#{img_obj.data_uri}' couldn't be downloaded by reason: '#{e}'"
                    @negative_counter += 1
                end
            end
        end
        
        def remove_file(file_path)
            #begin
                File.delete(file_path)
            #rescue Errno::ENOENT => e
                #no such file or directory
            #end
        end

        def base64_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path) unless File.exists?(arg_obj.path)
            File.write(arg_obj.path+"/"+img_obj.img_name.to_s+"."+img_obj.img_format, decoded_uri.data)
        end

        def link_encoded_uri_save_as_file(decoded_uri, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path)unless File.exists?(arg_obj.path)
            File.write(arg_obj.path+"/"+img_obj.img_name.to_s+"."+img_obj.img_format, decoded_uri)
        end

        def direct_link_save_as_file(path, img_obj, arg_obj)
            Dir.mkdir(arg_obj.path)unless File.exists?(arg_obj.path)
            #if folder creation was successfuly finished, then
            #I am saving file from direct link
            File.open("#{arg_obj.path}/#{img_obj.img_name}.#{img_obj.img_format}", 'wb') {|file| 
                file.write(open(path).read)
            }
        end
    end
end
