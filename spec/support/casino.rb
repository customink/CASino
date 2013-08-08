RSpec.configure do |config|
  config.around(type: :controller) do
    self.routes = CASino::Engine.routes
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