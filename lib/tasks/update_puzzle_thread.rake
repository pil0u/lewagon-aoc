# frozen_string_literal: true

desc "update_puzzle_thread"
task :update_puzzle_thread, %i[day channel] => :environment do |_, args|
  next p "day param missing" if args[:day].nil?
  next p "channel missing or incorrect" unless args[:channel].in? %w[aoc aoc-dev]

  puzzle = Puzzle.by_date(Aoc.begin_time.change(day: args[:day]))
  next p "Puzzle not found" if puzzle.nil?

  html = URI.parse(@puzzle.url).open
  doc = Nokogiri::HTML(html)
  titles = doc.css("h2").map(&:text)
  raw_title = titles.find { |title| title.match?(/--- Day \d+:/) }
  next p "Title not found" if raw_title.nil?

  client = Slack::Web::Client.new
  text = "`SPOILER` <#{@puzzle.url}|#{raw_title.gsub('---', '').strip}>"
  response = client.chat_update(channel: args[:channel], ts: puzzle.thread_ts, text:)
  next p "Failed to update message" unless response["ok"]

  puzzle.update!(title: text)
end
