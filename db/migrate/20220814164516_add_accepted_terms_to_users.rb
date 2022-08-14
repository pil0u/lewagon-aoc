# frozen_string_literal: true

class AddAcceptedTermsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :accepted_terms, :boolean, default: false
  end
end
