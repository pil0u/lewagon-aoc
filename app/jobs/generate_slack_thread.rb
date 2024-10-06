# frozen_string_literal: true

require "open-uri"

class GenerateSlackThread < ApplicationJob
  queue_as :default

  def perform(day)
    @day = day

    if title.present?
      post_message(channel: ENV.fetch("SLACK_CHANNEL", "#aoc-dev"), text: title)
    else
      post_message(channel: "#aoc-dev", text: "Title not found for day ##{@day}")
    end
  end

  private

  def client
    @client ||= Slack::Web::Client.new
  end

  def post_message(channel:, text:)
    # https://api.slack.com/methods/chat.postMessage
    client.chat_postMessage(channel:, text:)
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
