# frozen_string_literal: true

module Blazer
  class RunAllChecksJob < ApplicationJob
    def perform
      Blazer.run_checks
    end
  end
end
