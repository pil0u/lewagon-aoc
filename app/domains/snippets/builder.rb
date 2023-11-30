module Snippets
  class Builder
    def self.call(...)
      new(...).call
    end

    def call
      language = @attributes[:language]
      code = @attributes[:code]

      @attributes[:code] = markdown_wrapped(code, source_language: language) if code.present?

      Snippet.new(**@attributes)
    end

    def markdown_wrapped(code, source_language:)
      return code if code.match?(/```/) || source_language&.to_sym == :markdown

      <<~CODE
        ```#{source_language}
          #{code}
        ```
      CODE
    end

    def initialize(**attrs)
      @attributes = attrs.deep_dup
    end
  end
end
