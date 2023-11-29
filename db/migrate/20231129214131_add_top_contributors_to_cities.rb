# frozen_string_literal: true

class AddTopContributorsToCities < ActiveRecord::Migration[7.1]
  def change
    add_column :cities, :top_contributors, :integer
  end
end
