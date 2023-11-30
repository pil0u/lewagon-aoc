# frozen_string_literal: true

module Snippets
  class ReactionComponent < ApplicationComponent
    include ApplicationHelper

    EMOTES = {
      clapping: { emote: "👏", tooltip: "Nice solution, well done" },
      learning: { emote: "🎓", tooltip: "Outstanding solution to help others learn" },
      mind_blown: { emote: "🤯", tooltip: "Mind-blowing or unexpected solution" }
    }.freeze

    def initialize(snippet:, emote:, user:)
      @user = user
      @snippet = snippet
      @content = emote
      @reactions = @snippet.reactions.where(content: @content)
    end
  end
end
