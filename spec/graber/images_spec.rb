require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Graber::Images do

    before do
        @argument = double("Arguments", 
                          :path => './temp',
                          :url => 'http://www.test.com')
        @url_scheme = URI::split(@argument.url)
    end

    context 'base64' do
        before :all do
            @src = 'border-color: #f4f4f4; background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAbCAIAAAA70dJZAAAAK0lEQVR42mL8//8/AxJgpDf/379/NOX//fuXqvw/f/7QlP/79298fIAAAwDaGVBNDHs/egAAAABJRU5ErkJggg==") !important; cursor: default !important; *background-image: none !important;'
            @image = Graber::Images.new(@src, @url_scheme)
        end

        it 'sets name by counter if it is base64 encoded image' do
            expect(@image.img_name).to eql(2)
        end

        it 'initialize image link type as base64 encoded' do
          expect(@image.base64_encoded_uri).to be(true)  
        end

        it 'initialize image format' do
            expect(@image.img_format).to eql('png')
        end

        it 'initialize data uri' do
            expect(@image.data_uri).to eql('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAbCAIAAAA70dJZAAAAK0lEQVR42mL8//8/AxJgpDf/379/NOX//fuXqvw/f/7QlP/79298fIAAAwDaGVBNDHs/egAAAABJRU5ErkJggg==')
        end
    end


    context 'link encoded uri' do
        before :all do
            @src = "background-img_obj: url(\"data:image/svg+xml;charset=utf8,%3C?xml version='1.0' encoding='utf-8'?%3E %3C!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'%3E %3Csvg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='42px' height='42px' viewBox='0 0 42 42'%3E %3Cpath style='stroke-width:2px;stroke:%23000;opacity:0.6' d='M21 11l0 20M11 21l20 0'/%3E %3C/svg%3E \");"
            @image = Graber::Images.new(@src, @url_scheme)
        end

        it 'sets name by counter if it is UTF-8 encoded image' do
            expect(@image.img_name).to eql(3)
        end

        it 'initialize image link type as utf-8 encoded' do
          expect(@image.link_encoded_uri).to be(true)  
        end

        it 'initialize image format' do
            expect(@image.img_format).to eql('svg')
        end

        it 'initialize data uri' do
            expect(@image.data_uri).to eql("data:image/svg+xml;charset=utf8,%3C?xml version='1.0' encoding='utf-8'?%3E %3C!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'%3E %3Csvg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='42px' height='42px' viewBox='0 0 42 42'%3E %3Cpath style='stroke-width:2px;stroke:%23000;opacity:0.6' d='M21 11l0 20M11 21l20 0'/%3E %3C/svg%3E ")
        end
    end

    context 'direct link' do
        before :all do
            @src = "background-image: url(\"//test.net/www/_/i/Q/bMusJo2bHREZwwGmzzhi2COhU.png\");"
            @image = Graber::Images.new(@src, @url_scheme)
        end

        it 'initialize image name' do
            expect(@image.img_name).to eql('bMusJo2bHREZwwGmzzhi2COhU')
        end

        it 'initialize image type as utf-8 decoded' do
          expect(@image.direct_link).to be(true)  
        end

        it 'initialize image format' do
            expect(@image.img_format).to eql('png')
        end

        it 'initialize data uri' do
            expect(@image.data_uri).to eql('http://test.net/www/_/i/Q/bMusJo2bHREZwwGmzzhi2COhU.png')
        end
    end

    it 'recieves error if downloaded file not exist' do
        image = Graber::Images.new('//test.com/test_path.jpg', @url_scheme)
        expect{image.remove_file('./temp/test_path.jpg')}.to raise_error(Errno::ENOENT)
    end
end
