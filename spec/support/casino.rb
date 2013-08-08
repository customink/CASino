require 'active_support/core_ext/hash/deep_dup'

RSpec.configure do |config|
  config.around(type: :controller) do
    self.routes = CASino::Engine.routes
  end

  config.before do
    @base_config = CASino.config.deep_dup
  end

  config.after do
    CASino.config.clear
    CASino.config.merge! @base_config
  end
end

class CASinoCore::Model::LoginTicket < ActiveRecord::Base
  self.table_name = 'casino_login_tickets'
end

class CASinoCore::Model::ServiceTicket < ActiveRecord::Base
  self.table_name = 'casino_service_tickets'
end

class CASinoCore::Model::TicketGrantingTicket < ActiveRecord::Base
  self.table_name = 'casino_ticket_granting_tickets'
end

class CASinoCore::Model::TwoFactorAuthenticator < ActiveRecord::Base
  self.table_name = 'casino_two_factor_authenticators'
end

class CASinoCore::Model::User < ActiveRecord::Base
  self.table_name = 'casino_users'
end