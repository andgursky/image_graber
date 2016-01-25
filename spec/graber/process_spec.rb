require File.expand_path(File.dirname(__FILE__) + '/../spec_helper') 

describe Graber::Process do
    def mock_parser
        parser = double(Graber::Parser)
        expect(Graber::Parser).to receive(:new).with('http://www.test.com', './temp').and_return(parser)
        parser
    end

    def stub_parser_methods(parser)
        allow(parser).to receive(:get_content)
        allow(parser).to receive(:css_file_searching_in_html)
        allow(parser).to receive(:img_searching_in_html)
        allow(parser).to receive(:img_hash)
    end

    before do
        @process = Graber::Process.new('www.test.com', './temp')
    end

    it 'normalize url' do
        expect(@process.argument.url).to eq('http://www.test.com')
    end
    
    it 'does not change correct url' do
        process = Graber::Process.new('https://www.test.com', ',/temp')
        expect(process.argument.url).to eq('https://www.test.com')
    end

    describe '.parse' do
        before do
            @parser = mock_parser
            stub_parser_methods(@parser)
        end
        
        it 'expects to call get_content function' do
            expect(@parser).to receive(:get_content)
            @process.parse
        end

        it 'expects to call css_file_searching_in_html function' do
            expect(@parser).to receive(:css_file_searching_in_html)
            @process.parse
        end

        it 'expects to call img_searching_in_html function' do
            expect(@parser).to receive(:img_searching_in_html)
            @process.parse
        end

        it 'expects to call img_searching_in_html function' do
            expect(@parser).to receive(:img_searching_in_html)
            @process.parse
        end

        it 'expects to call img_hash function' do
            expect(@parser).to receive(:img_hash)
            @process.parse
        end
    end

    describe '.download' do

        it 'calls parallel method of download class' do
            expect(Graber::Download).to receive(:parallel).with({}, @process.argument)
            @process.download
        end
    end
end
