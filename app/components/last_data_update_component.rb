# frozen_string_literal: true

class LastDataUpdateComponent < ApplicationComponent
  def initialize
    @now = Time.now.utc
    @last_update = State.first.last_api_fetch_end.utc # TODO: caching?
  end
end
