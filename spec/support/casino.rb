RSpec.configure do |config|
  config.before(:each, type: :controller) do
    @routes = CASino::Engine.routes
  end
end