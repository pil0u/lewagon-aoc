module Snippets
  class Builder
    def self.call(...)
      new(...).call
    end

    def call
      code = @attributes[:code]

      code = markdown_wrapped(code, source_language: @attributes[:language]) if code.present?

      Snippet.new(**@attributes, code: code)
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
      @attributes = attrs
    end
  end
end
