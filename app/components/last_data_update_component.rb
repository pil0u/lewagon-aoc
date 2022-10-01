# frozen_string_literal: true

class LastDataUpdateComponent < ApplicationComponent
  def initialize
    @now = Time.now.utc
    @last_update = State.last.fetch_api_end.utc
  end
end
