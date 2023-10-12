class AddYearToBatches < ActiveRecord::Migration[7.1]
  def change
    add_column :batches, :year, :string
  end
end
