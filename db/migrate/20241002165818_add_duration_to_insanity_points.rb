# frozen_string_literal: true

class AddDurationToInsanityPoints < ActiveRecord::Migration[7.1]
  def change
    add_column :insanity_points, :duration, :interval
  end
end
