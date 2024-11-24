# frozen_string_literal: true

module Snippets
  class BoxComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :snippet

    def initialize(snippet:, user:)
      @user = user
      @snippet = snippet

      @user_can_edit_snippet = @snippet.user == @user
      @user_reaction_vote_value = @snippet.reactions.find { _1.user_id == @user.id }
    end
  end
end
