module Graber
    class Download
        #This class will make the process of storing images multithread
        def self.parallel(img_hash, argument)
            threads = []
            img_hash.each{|key, val|
                threads << Thread.new(val){|image|
                    image.download(image, argument)
                }
            }
            binding.pry
        end
    end
end
