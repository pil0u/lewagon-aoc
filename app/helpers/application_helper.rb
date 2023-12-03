# frozen_string_literal: true

module ApplicationHelper
  def duration_as_text(duration)
    return "-" if duration.nil?

    if duration < 48.hours
      parts = duration.parts
      [parts[:hours].to_i + (24 * parts[:days].to_i), parts[:minutes].to_i, parts[:seconds].to_i].map { |n| n.to_i.to_s.rjust(2, "0") }.join(":")
    else
      ">48h"
    end
  end

  def messages_sanitizer(text)
    sanitize(text, tags: %w[b em del span sub sup], attributes: %w[style])
  end

  DEFAULT_THEME = "base16-ocean.dark"

  def render_markdown(commonmarkdown, default_language: nil)
    ast = CommonMarker.render_doc(commonmarkdown)
    ast.walk do |node|
      next unless node.type == :code_block

      language = node.fence_info.presence || default_language
      lexer = ::Rouge::Lexer.find_fancy(language) || ::Rouge::Lexers::PlainText.new

      formatter = Rouge::Formatters::HTML.new
      code_html = formatter.format(lexer.lex(node.string_content))
      html = %(<pre class="code-highlighter" lang="#{lexer.class.title}">#{code_html}</pre>)
      new_node = ::CommonMarker::Node.new(:html)
      new_node.string_content = html

      node.insert_before(new_node)
      node.delete
    end
    ast.to_html(:UNSAFE)
  end
end
