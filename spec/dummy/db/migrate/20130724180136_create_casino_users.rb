class CreateCASinoUsers < ActiveRecord::Migration
  def change
    create_table :casino_users do |t|
      t.string  :authenticator,   :null => false
      t.string  :username,        :null => false
      t.text    :extra_attributes

      t.timestamps
    end
    add_index :casino_users, [:authenticator, :username], :name => "index_casino_users_on_authenticator_and_username", :unique => true
  end
end