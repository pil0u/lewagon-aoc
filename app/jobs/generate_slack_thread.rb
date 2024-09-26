# frozen_string_literal: true

require "open-uri"

class GenerateSlackThread < ApplicationJob
  queue_as :default

  def perform(day)
    @day = day

    if title.present?
      post_message
    else
      post_message("Title not found for day ##{@day}", "#aoc-dev")
    end
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def post_message(text = title, channel = ENV.fetch("SLACK_CHANNEL"))
    # https://api.slack.com/methods/chat.postMessage
    client.chat_postMessage(as_user: true, channel:, text:)
  end

  def title
    @title ||= begin
      html = URI.parse(Aoc.url(@day)).open
      doc = Nokogiri::HTML(html)
      titles = doc.css("h2").map(&:text)
      raw_title = titles.find { |title| title.match?(/--- Day \d+:/) }

      "`SPOILER` <#{Aoc.url(@day)}|#{raw_title.gsub('---', '').strip}>" if raw_title.present?
    rescue OpenURI::HTTPError
      nil
    end
  end
end
