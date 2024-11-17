# frozen_string_literal: true

module Snippets
  class BoxComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :snippet

    def initialize(snippet:, user:)
      @user = user
      @snippet = snippet

      @user_can_edit_snippet = @snippet.user == @user
    end
  end
end
