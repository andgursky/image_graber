require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 


describe Graber::URL do

    before do
        @url_scheme = URI::split('http://www.test.com')
    end

    it 'false for url without http' do
        expect(Graber::URL.contain_http?("www.test.com")).to be false  
    end 

    it 'true for url with http' do
        expect(Graber::URL.contain_http?("http://test.com")).to be true
    end

    it 'true for url with https' do
        expect(Graber::URL.contain_http?("https://test.com")).to be true
    end

    it 'normalize url without http' do
        expect(Graber::URL.normalize("www.test.com")).to eql("http://www.test.com")
    end

    it 'not normalize url with http' do
        expect(Graber::URL.normalize("http://www.test.com")).to eql("http://www.test.com")
    end

    it 'not normalize url with https' do
        expect(Graber::URL.normalize("https://www.test.com")).to eql("https://www.test.com")
    end

    it 'removes \\n and \\r from string' do
        expect(Graber::URL.remove_new_line_symbols!("https://www.te\nst.c\rom")).to eql("https://www.test.com")
    end

    it 'adding www to url' do
        expect(Graber::URL.add_www_to_url('http://test.com')).to eql('http://www.test.com')
    end

    it 'removes double slashes at the begining of url' do
        expect(Graber::URL.remove_double_slashes_if_they_exists('//test.com/index.html')).to eql('test.com/index.html')
    end

    it 'true for uri path' do
        expect(Graber::URL.is_it_uri_path?('/catalog/index.html')).to be true 
    end

    it 'false for host' do
        expect(Graber::URL.is_it_uri_path?('//test.com/index.html')).to be false
    end

    it 'change http on https' do
        expect(Graber::URL.redirections_scheme('http://test.com')).to eql('https://test.com') 
    end

    it 'change https on http' do
        expect(Graber::URL.redirections_scheme('https://test.com')).to eql('http://test.com') 
    end

    it 'adding url scheme and host to url path' do
        expect(Graber::URL.normalize_url_with_scheme_and_host('/path/pic.png', @url_scheme)).to eql('http://www.test.com/path/pic.png') 
    end

    it 'returning url if it is not path' do
        expect(Graber::URL.normalize_url_with_scheme_and_host('http://test.com/path/pic.png', @url_scheme)).to eql('http://test.com/path/pic.png') 
    end

    it 'returns url with http if it is not path and it has not http or https url scheme' do
        expect(Graber::URL.normalize_url_with_scheme_and_host('//test.com/path/pic.png', @url_scheme)).to eql('http://test.com/path/pic.png') 
    end
end
