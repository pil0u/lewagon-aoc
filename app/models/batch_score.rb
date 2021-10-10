# frozen_string_literal: true

class BatchScore < ApplicationRecord
  belongs_to :batch
  belongs_to :user
end
