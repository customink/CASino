require 'addressable/uri'
require 'casino/url_cleaner'
require_relative 'ticket_generation'
require_relative 'proxy_tickets'

module CASino
  module ProcessorConcerns
    module ServiceTickets
      include CASino::UrlCleaner
      include TicketGeneration
      include ProxyTickets

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        service_url = clean_service_url(service)
        unless CASino::ServiceRule.allowed?(service_url)
          message = "#{service_url} is not in the list of allowed URLs"
          Rails.logger.error message
          raise CASino::ServiceNotAllowedError, message
        end
        ticket_granting_ticket.service_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: service_url,
          issued_from_credentials: !!credentials_supplied
        })
      end
    end
  end
end
