require 'spec_helper'

describe CASino::ProcessorConcerns::Authentication do

  let(:abstract_class) do
    Class.new do
      include CASino::ProcessorConcerns::Authentication
    end
  end

  before do
    stub_const 'Container', abstract_class
  end

  subject { Container.new }

  describe '#authenticators' do
    subject { super().authenticators }

    context 'with an un-instantiated authenticator' do
      before do
        CASino.configure do |cfg|
          cfg.authenticators[:mock] = auth
        end
      end

      context 'that includes an explicit class name' do
        let(:auth) do
          {
            class: 'CASino::StaticAuthenticator',
            options: {}
          }
        end

        it 'instantiates them' do
          expect(subject[:mock]).to be_an_instance_of CASino::StaticAuthenticator
        end
      end

      context 'that includes a Gem name' do
        let(:auth) do
          {
            authenticator: name,
            options: {}
          }
        end

        let(:name) { 'Mock' }

        it 'instantiates them' do
          expect(subject[:mock]).to be_an_instance_of CASino::MockAuthenticator
        end

        context 'that does not exist' do
          let(:name) { 'ActiveRecord' }

          it 'raises a custom LoadError' do
            expect{subject[:mock]}.to raise_error LoadError,
              %r{Failed to load authenticator 'ActiveRecord'. Maybe you have to include "gem 'casino-active_record_authenticator'"}
          end
        end

        context 'that is improperly namespaced' do
          before do
            CASino.stub(:const_get) do |name|
              raise(NameError, 'foo') if name == 'MockAuthenticator'
              eval "CASino::#{name}"
            end
          end

          it 'raises a custom NameError' do
            expect{subject[:mock]}.to raise_error NameError,
              %r{Failed to load authenticator 'Mock'. The authenticator class must be defined in the CASino namespace.}
          end
        end
      end

    end
  end

end