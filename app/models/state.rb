# frozen_string_literal: true

class State < ApplicationRecord
  before_create :prevent_create

  private

  def prevent_create
    throw :abort unless State.count == 0
  end
end
