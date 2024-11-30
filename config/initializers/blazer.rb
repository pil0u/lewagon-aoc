# frozen_string_literal: true

if Rails.env.production?
  ENV["BLAZER_USERNAME"] = Rails.application.credentials.dig(:blazer, :username)
  ENV["BLAZER_PASSWORD"] = Rails.application.credentials.dig(:blazer, :password)
end

ENV["BLAZER_SLACK_WEBHOOK_URL"] = Rails.application.credentials.dig(:blazer, :slack_webhook_url)
