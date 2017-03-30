require 'spec_helper'

describe 'WebtrzisteCz' do
  before :context do
    # @klass = WebtrzisteCz.new
    # @klass = OvocnarskaUnieCz.new
    # @klass = NalokCz.new
    @klass = EdbCz.new
  end

  it 'should be ok' do
    p @klass
  end

  context 'find_categories' do
    let(:categories) { @klass.find_categories }

    it 'should has categories' do
      expect(categories.size).to be > 0
    end

    context 'find urls' do
      let(:urls) { @klass.find_urls(categories[0..0]) }

      it 'should has urls' do
        p urls
        expect(urls.size).to be > 0
      end

      context 'process_url' do
        let(:response) { @klass.process_url(urls[0]) }

        it 'shouls has data' do
          p response
        end
      end
    end
  end
end
