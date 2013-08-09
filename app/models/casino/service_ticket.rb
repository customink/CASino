class CASino::ServiceTicket < ActiveRecord::Base
  attr_accessible :ticket, :service, :issued_from_credentials
  validates :ticket, uniqueness: true
  belongs_to :ticket_granting_ticket
  before_destroy :send_single_sing_out_notification, if: :consumed?
  has_many :proxy_granting_tickets, as: :granter, dependent: :destroy

  def self.cleanup_unconsumed
    self.destroy_all(['created_at < ? AND consumed = ?', CASino.config.service_ticket[:lifetime_unconsumed].seconds.ago, false])
  end

  def self.cleanup_consumed
    self.destroy_all(['(ticket_granting_ticket_id IS NULL OR created_at < ?) AND consumed = ?', CASino.config.service_ticket[:lifetime_consumed].seconds.ago, true])
  end

  def self.cleanup_consumed_hard
    self.delete_all(['created_at < ? AND consumed = ?', (CASino.config.service_ticket[:lifetime_consumed].seconds * 2).ago, true])
  end

  def service_with_ticket_url
    service_uri = Addressable::URI.parse(self.service)
    service_uri.query_values = (service_uri.query_values(Array) || []) << ['ticket', self.ticket]
    service_uri.to_s
  end

  def expired?
    lifetime = if consumed?
      CASino.config.service_ticket[:lifetime_consumed]
    else
      CASino.config.service_ticket[:lifetime_unconsumed]
    end
    (Time.now - (self.created_at || Time.now)) > lifetime
  end

  private
  def send_single_sing_out_notification
    notifier = CASino::SingleSignOutNotifier.new(self)
    notifier.notify
    true
  end
end
