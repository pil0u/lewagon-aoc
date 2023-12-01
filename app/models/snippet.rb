# frozen_string_literal: true

class Snippet < ApplicationRecord
  # All snippets are technically Markdown (cf. http://github.github.com/gfm/)
  # but they have a declared language to be categorized and filtered
  LANGUAGES = {
    c: "C",
    cpp: "C++",
    crystal: "Crystal",
    csharp: "C#",
    dart: "Dart",
    elixir: "Elixir",
    go: "Go",
    haskell: "Haskell",
    java: "Java",
    javascript: "JavaScript",
    kotlin: "Kotlin",
    markdown: "Markdown",
    matlab: "MATLAB",
    ocaml: "OCaml",
    pascal: "Pascal",
    php: "PHP",
    python: "Python",
    r: "R",
    ruby: "Ruby",
    rust: "Rust",
    sql: "SQL",
    swift: "Swift",
    typescript: "TypeScript"
  }.freeze

  belongs_to :user

  has_many :reactions, dependent: :destroy

  validates :code, presence: true
  validates :language, inclusion: { in: LANGUAGES.keys.map(&:to_s) }
  validates :user_id, uniqueness: { scope: %i[day challenge language], message: "can submit only 1 solution per language" }
end
