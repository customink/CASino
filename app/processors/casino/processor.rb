class CASino::Processor
  def initialize(listener)
    @listener = listener
  end

  module Api
  end
end

# Alias the Api namespace in case the host application has added an acronym
# inflection mapping "api" to "API"
CASino::Processor::API = CASino::Processor::Api
