class CreateBuddies < ActiveRecord::Migration[7.1]
  def change
    create_table :buddies do |t|
      t.integer :id_1
      t.integer :id_2
      t.integer :day

      t.timestamps
    end
  end
end
