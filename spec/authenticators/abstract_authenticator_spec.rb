require 'spec_helper'

describe CASino::AbstractAuthenticator do
  context '#validate' do
    it 'raises an error' do
      expect { subject.validate(nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end
