class CreateCASinoProxyTickets < ActiveRecord::Migration
  def change
    create_table :casino_proxy_tickets do |t|
      t.string  :ticket,                                      :null => false
      t.string  :service,                                     :null => false
      t.boolean :consumed,                 :default => false, :null => false
      t.integer :proxy_granting_ticket_id,                    :null => false

      t.timestamps
    end
    add_index :casino_proxy_tickets, :ticket, :name => "index_casino_proxy_tickets_on_ticket", :unique => true
    add_index :casino_proxy_tickets, :proxy_granting_ticket_id, :name => "index_casino_proxy_tickets_on_proxy_granting_ticket_id"
  end
end