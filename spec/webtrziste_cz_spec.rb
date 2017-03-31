require 'spec_helper'

describe 'Product' do
  before :context do
    # @klass = WebtrzisteCz.new
    # @klass = OvocnarskaUnieCz.new
    # @klass = NalokCz.new
    # @klass = EdbCz.new
    # @klass = BioInfoCz.new
    # @klass = CeskyFarmarCz.new
    # @klass = FarmarNaDlaniCz.new
    # @klass = AdresarFarmaruCz.new
    # @klass = VeronicaCz.new
    @klass = NajdiSiVcelareCz.new
  end

  it 'should be ok' do
    p @klass
  end

  context 'find_categories' do
    let(:categories) { @klass.find_categories }

    it 'should has categories' do
      p categories
      expect(categories.size).to be > 0
    end

    context 'find urls' do
      let(:urls) { @klass.find_urls(categories[0..0]) }

      it 'should has urls' do
        p urls
        expect(urls.size).to be > 0
      end

      context 'process_url' do
        let(:response) { @klass.process_url('https://www.najdisivcelare.cz/prodej-medu-hradec-kralove/328-prodej-medu-vladimir-dolezal-a-zuzana-samlekova-okres-hradec-kralove.html') }

        it 'shouls has data' do
          p response
        end
      end
    end
  end
end
