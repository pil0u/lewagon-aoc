# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Builder do
  let(:language) { :markdown }
  let(:code) { <<-MARKDOWN }
    Hello ! This is *my* solution !
  MARKDOWN

  it "builds a snippet with the provided attributes" do
    result = described_class.call(code:, language:)
    expect(result).to be_a Snippet
    expect(result.attributes.symbolize_keys).to include(code:, language: "markdown")
  end

  context "when submitted straight code" do
    let(:language) { :ruby }
    let(:code) { <<-RUBY }
      puts "My solution"
    RUBY

    it "wraps the code in a fenced block of specified language" do
      result = described_class.call(code:, language:)
      expect(result).to be_a Snippet
      expect(result.attributes.symbolize_keys).to include(code: "```ruby\n#{code}\n```\n", language: "ruby")
    end
  end
end
