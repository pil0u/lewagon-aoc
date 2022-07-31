# frozen_string_literal: true

class LastDataRefreshComponent < ApplicationComponent
  def initialize
    @now = Time.now.utc
    @last_refresh = State.first.last_api_fetch_end.utc # TODO: caching?
  end
end
