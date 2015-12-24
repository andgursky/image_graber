module Graber
    class URL

        def self.contain_http?(url)
            url =~ /^(http|https)/i ? true : false
        end

        def self.normalize(url)
            contain_http?(url) ? url : 'http://' + url
        end

        def self.remove_new_line_symbols!(str)
            str.gsub!(/\r/,'') if str
            str.gsub!(/\n/,'') if str
        end

        def self.normalize_url_with_scheme_and_host(url, url_scheme)
            if self.is_it_uri_path?(url)
                # here will be uri.scheme + uri.host + uri.path
                # uri.scheme and host should not be nil 
                return url_scheme[0] + "://" + url_scheme[2] + url unless !url_scheme[0] && !url_scheme[2] 
                return url
            else
                URL.contain_http?(url) ? url : 'http://'+ remove_double_slashes_if_they_exists(url)
            end
        end

        def self.add_www_to_url(url)
            url_split = URI::split(url)
            return "#{url_split[0]}://www.#{url_split[2]}#{url_split[5]}" unless /^[http:\/\/|https:\/\/|\/\/]*w{3}\./=~url
        end

        def self.remove_double_slashes_if_they_exists(url) #if url starts with one slash, it's means, that before slash must be host name
            str = ""
            url.gsub(/(?<=[\/\/])[^\/].*/){|x|
                str =  x}
            return str ? str : url
        end
        
        def self.is_it_uri_path?(url) #if this is path (/photos/1.jpg = true) else url (//google.com)
           pattern_single_slash = /^\//
           pattern_double_slash = /^\/\//
           if(pattern_single_slash =~ url && !(pattern_double_slash =~ url))
               return true
           else
               return false
           end
        end


        def self.redirections_scheme(url)
            pattern = /^.+(?=\:\/\/)/
            uri_splited = URI::split(url)

            url.gsub(pattern){|x|
                if(x=="http")
                    return "https://#{uri_splited[2]}"
                else
                    return "http://#{uri_splited[2]}"
                end
            }
        end
    end
end
