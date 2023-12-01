# frozen_string_literal: true

module Snippets
  class Builder

    FENCE_TYPES = ["```", "~~~"].freeze

    def self.call(...)
      new(...).call
    end

    def call
      code = @attributes[:code]

      code = markdown_wrapped(code, source_language: @attributes[:language]) if code.present?

      Snippet.new(**@attributes, code:)
    end

    def markdown_wrapped(code, source_language:)
      implicitly_markdown = FENCE_TYPES.any? { |fence| code.include?(fence) }
      explicitly_markdown = source_language&.to_sym == :markdown

      return code if implicitly_markdown || explicitly_markdown

      <<~CODE
        ```#{source_language}
        #{code}
        ```
      CODE
    end

    def initialize(**attrs)
      @attributes = attrs
    end
  end
end
