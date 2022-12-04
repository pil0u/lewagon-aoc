# frozen_string_literal: true

module ApplicationHelper
  def duration_as_text(duration)
    return "-" if duration.nil?

    if duration < 48.hours
      parts = duration.parts
      [parts[:hours] || 0, parts[:minutes] || 0, parts[:seconds] || 0].map { |n| n.to_i.to_s.rjust(2, "0") }.join(":")
    else
      ">48h"
    end
  end

  def messages_sanitizer(text)
    sanitize(text, tags: %w[b em del span sub sup], attributes: %w[style])
  end

  def snippets_sanitizer(text)
    sanitize(text).gsub!('&gt;', '>').gsub!('&lt;', '<')
  end

  def rouge(text, language)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexer.find(language)
    formatter.format(lexer.lex(text))
  end
end
