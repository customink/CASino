RSpec.configure do |config|
  config.around(type: :controller) do
    self.routes = CASino::Engine.routes
  end
end