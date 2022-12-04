# frozen_string_literal: true

class InsertNewCompletionsJob < ApplicationJob
  queue_as :default

  def perform
    Completions::Fetcher.call
  end
end
