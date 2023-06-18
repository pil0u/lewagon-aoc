# frozen_string_literal: true

module Cache
  class UserDayScore < ApplicationRecord
    belongs_to :user
    belongs_to :part_1_completion, class_name: "Completion", optional: true
    belongs_to :part_2_completion, class_name: "Completion", optional: true
  end
end
