require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 
require 'ostruct'
require 'pry'

describe Graber::Parser do

    def create_parser(h = {})
        parser = Graber::Parser.new("http://test.com", "./temp") 
        file = h[:nokogiri] ? h[:html] : OpenStruct.new(:read => h[:html]) 
        allow(parser).to receive(:open_url).and_return(file)
        parser
    end
    

    subject(:images){parser.img_hash.size}

    
    describe ".css_file_searching_in_html" do
        def css_file_in_head
            "<style>.b-sethome__popupa-content{margin:20px 5px 0 15px;padding-top:55px}.b-sethome__popupa-text{margin-bottom:5px;width:240px}.b-sethome_browser_ff__old-bg{background:url(\"//yastatic.net/www/_/H/2/imQKfJXWJsc3wVS10GguLCJfc.png\") no-repeat 80% 0;width:330px;</style><link href=\"//test.com/www/_/p/4/sdfghdslk_dkhf.css\" rel=\"stylesheet\">Refresh page</link>"
        end

        def create_nokogiri_parser_and_searching_css(h = {})
            h[:nokogiri] = true
            parser = create_parser(h)
            parser.get_content
            parser.css_file_searching_in_html
            parser
        end

        context 'geting images from styles' do
            context 'no content, no images' do
                let(:parser){create_nokogiri_parser_and_searching_css({:html => ""})}
                it {expect(images).to be 0}
            end

            context 'has one image in styles' do
                let(:parser){create_nokogiri_parser_and_searching_css({:html => css_file_in_head})}
                it {expect(images).to eq(1)}
                specify { expect(parser.img_hash.values[0].img_format).to eq("png") }
                specify { expect(parser.img_hash.values[0].img_name).to eq("imQKfJXWJsc3wVS10GguLCJfc") }
            end
        end
    end

    describe  ".img_searching_in_html" do
        def one_img_in_img_tag
            "<body><div><img src=\"//test.com/1_pic_name.gif\"></div></body>"
        end

        def two_imgs_in_img_tag
            "<body><div><img src=\"//test.com/1_pic_name.gif\"><img src=\"//test.com/2_pic_name.gif\"></div></body>"
        end
        
        def create_nokogiri_parser_and_searching_in_html(h = {})
            h[:nokogiri] = true
            parser = create_parser(h)
            parser.get_content
            parser.img_searching_in_html
            parser
        end

        context 'getting images from html tag' do
            context 'has one image' do
                let(:parser){create_nokogiri_parser_and_searching_in_html({:html => one_img_in_img_tag})}
                it {expect(images).to eq(1)}
            end
                
            context 'has multiple images' do
                let(:parser){create_nokogiri_parser_and_searching_in_html({:html => two_imgs_in_img_tag})}
                it {expect(images).to eq(2)}
            end
        end
    end

end
