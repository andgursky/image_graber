module Graber
    class Download
        attr_accessor :counter

        #This class will make the process of storing images multithread
        def self.parallel(img_hash, argument)
            threads = []
            @counter = 0
            puts "There is #{img_hash.size} image objects detected"
            img_hash.each{|key, val|
                threads << Thread.new(val){|image|
                    image.download(image, argument)
                    @counter += 1
                    @counter -= image.negative_counter
                }
            }
            threads.each {|thread| thread.join}
            puts "The #{@counter} of them was successfuly downloaded"
        end

        def self.remove_file(file)
            begin
                File.delete(file)
            rescue Errno::ENOENT => e
                #no such file or directory
            end
        end
    end
end
