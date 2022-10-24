# frozen_string_literal: true

class AddSponsorTierToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sponsor_tier, :text
    add_column :users, :sponsor_since, :datetime
  end
end
