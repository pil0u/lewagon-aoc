# frozen_string_literal: true

class UserFormComponent < ApplicationComponent
  def initialize(user:)
    @user = user
  end
end
