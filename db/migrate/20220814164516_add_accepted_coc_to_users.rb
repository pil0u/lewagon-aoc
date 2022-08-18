# frozen_string_literal: true

class AddAcceptedCocToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :accepted_coc, :boolean, default: false
  end
end
