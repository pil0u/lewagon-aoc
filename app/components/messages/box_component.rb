# frozen_string_literal: true

class Messages::BoxComponent < ApplicationComponent
  include ApplicationHelper

  with_collection_parameter :message

  def initialize(message:, user:)
    @message = message
    @user = user
  end
end
