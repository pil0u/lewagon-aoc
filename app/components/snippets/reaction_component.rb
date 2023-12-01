# frozen_string_literal: true

module Snippets
  class ReactionComponent < ApplicationComponent
    include ApplicationHelper

    # We might be able to move this to locales(? config for the emojis?) and make it fully dynamic
    EMOTES = {
      clapping: { emote: "👏", tooltip: "Nice solution, well done" },
      learning: { emote: "🎓", tooltip: "Outstanding solution to help others learn" },
      mind_blown: { emote: "🤯", tooltip: "Mind-blowing or unexpected solution" }
    }.freeze

    def initialize(snippet:, reaction_type:, user:)
      @user = user
      @snippet = snippet
      @reaction_type = reaction_type
      @reactions = @snippet.reactions.where(reaction_type:)
    end
  end
end
