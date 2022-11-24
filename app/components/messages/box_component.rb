# frozen_string_literal: true

module Messages
  class BoxComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :message

    def initialize(message:, user:)
      @message = message
      @user = user
    end
  end
end
