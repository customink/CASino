class CreateCASinoLoginTickets < ActiveRecord::Migration
  def change
    create_table :casino_login_tickets do |t|
      t.string :ticket

      t.timestamps
    end
    add_index :casino_login_tickets, :ticket, :name => "index_casino_login_tickets_on_ticket", :unique => true
  end
end
