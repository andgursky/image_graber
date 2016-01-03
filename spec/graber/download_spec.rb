require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Graber::Download do
    def img_declaration
        "background-image: url(\"//yastatic.net/www/_/i/Q/bMusJo2bHREZwwGmzzhi2COhU.png\");"
    end

    def url_scheme
        URI::split('http://www.test.com')
    end

    let(:arg){Graber::Arguments.new('http://www.test.com', './temp')}

    before do
        @image1 = Graber::Images.new(img_declaration, url_scheme)
        @image2 = Graber::Images.new(img_declaration, url_scheme)
        allow(@image1).to receive(:download)
        allow(@image2).to receive(:download)
    end

    describe '.parallel' do
        it 'calls thread new' do
            thread = Thread.new(@image1){|local_image| true}
            expect(Thread).to receive(:new).with(@image1).and_return(thread)
            Graber::Download.parallel({'http://test.com/img.gif'=>@image1}, arg)
        end

        it 'calls image.download' do
            expect(@image1).to receive(:download)
            Graber::Download.parallel({'http://test.com/img.gif'=>@image1}, arg)
        end

        it 'calls image.download for all images' do
            expect(@image1).to receive(:download)
            expect(@image2).to receive(:download)
            Graber::Download.parallel({'http://test.com/img1.gif'=>@image1,
                                       'http://test.com/img2.gif'=>@image2}, arg)
        end
    end

    describe '.remove_file' do
        it ' calls File.delete' do
           expect(File).to receive(:delete)
           Graber::Download.remove_file('./temp/img1.gif')
        end
    end
end
