# frozen_string_literal: true

module Snippets
  class BoxComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :snippet

    def initialize(snippet:)
      @snippet = snippet
    end
  end
end
