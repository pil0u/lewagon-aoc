# frozen_string_literal: true

module Scores
  def self.insert(scores)
    if scores.any?
      Rails.logger.info "  Erasing all scores..."
      Score.delete_all

      Rails.logger.info "  Inserting new scores..."
      Score.insert_all(scores, unique_by: %i[user_id day challenge])
    else
      Rails.logger.info "Nothing to do!"
    end
  end
end
