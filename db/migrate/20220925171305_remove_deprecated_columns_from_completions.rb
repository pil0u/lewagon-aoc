# frozen_string_literal: true

class RemoveDeprecatedColumnsFromCompletions < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_columns :completions, :rank_in_batch, :rank_in_city, :rank_solo, :score_in_batch, :score_in_city, :score_solo }
  end
end
