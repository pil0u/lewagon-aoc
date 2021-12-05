# frozen_string_literal: true

class RenameScoresToCompletions < ActiveRecord::Migration[6.1]
  def change
    rename_table :scores, :completions
  end
end
