# frozen_string_literal: true

module Snippets
  class BoxComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :snippet

    def initialize(snippet:, user:)
      @user = user
      @snippet = snippet

      @user_can_edit_snippet = @snippet.user == @user && Time.now.utc < Aoc.release_time(@snippet.day) + 48.hours
      @user_can_discuss_snippet = @snippet.user != @user && @snippet.user.slack_linked?
    end
  end
end
