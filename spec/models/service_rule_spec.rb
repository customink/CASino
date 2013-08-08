require 'spec_helper'

describe CASino::ServiceRule do
  describe '.allowed?' do
    context 'with an empty table' do
      ['https://www.example.org/', 'http://www.google.com/'].each do |service_url|
        it "allows access to #{service_url}" do
          described_class.allowed?(service_url).should == true
        end
      end
    end

    context 'with a regex rule' do
      before(:each) do
        create :service_rule, :regex, url: '^https://.*'
      end

      ['https://www.example.org/', 'https://www.google.com/'].each do |service_url|
        it "allows access to #{service_url}" do
          described_class.allowed?(service_url).should == true
        end
      end

      ['http://www.example.org/', 'http://www.google.com/'].each do |service_url|
        it "does not allow access to #{service_url}" do
          described_class.allowed?(service_url).should == false
        end
      end
    end

    context 'with many regex rules' do
      before(:each) do
        100.times do |counter|
          create :service_rule, :regex, url: "^https://www#{counter}.example.com"
        end
      end

      let(:service_url) { 'https://www111.example.com/bla' }

      it 'does not take too long to check a denied service' do
        start = Time.now
        described_class.allowed?(service_url).should == false
        (Time.now - start).should < 0.1
      end
    end

    context 'with a non-regex rule' do
      before(:each) do
        create :service_rule, url: 'https://www.google.com/foo'
      end

      ['https://www.google.com/foo'].each do |service_url|
        it "allows access to #{service_url}" do
          described_class.allowed?(service_url).should == true
        end
      end

      ['https://www.example.org/', 'http://www.example.org/', 'https://www.google.com/test'].each do |service_url|
        it "does not allow access to #{service_url}" do
          described_class.allowed?(service_url).should == false
        end
      end
    end
  end

  describe '#unsafe_regex?' do
    let(:params) { { url:url, regex:true } }

    subject { described_class.new(params).unsafe_regex? }

    context 'with an unsafe Regex-style URL' do
      let(:url) { '[a-z]' }

      it { should be_true }
    end

    context 'with an safe Regex-style URL' do
      let(:url) { '^[a-z]' }

      it { should be_false }
    end
  end

  describe '.add' do
    let(:name) { 'google' }
    let(:url) { 'http://google.com' }

    subject { described_class.add(name, url) }

    context 'and valid rule parameters' do
      it 'adds a new rule' do
        expect{subject}.to change{described_class.count}.by(1)
      end
    end

    context 'and invalid rule parameters' do
      let(:name) { '' }

      it 'raises an error' do
        expect{subject}.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context 'and an unsafe Regex' do
      let(:url) { 'regex:[a-z]' }

      before do
        Rails.logger.stub(:warn).and_call_original
      end

      it 'logs a warning' do
        subject

        expect(Rails.logger).to have_received(:warn)
      end
    end
  end
end
