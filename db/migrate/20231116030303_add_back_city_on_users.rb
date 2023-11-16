class AddBackCityOnUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :users, :city, index: { algorithm: :concurrently }
    add_foreign_key :users, :cities, validate: false
  end
end
