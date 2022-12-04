# frozen_string_literal: true

class Snippet < ApplicationRecord
  LANGUAGES = {
    c: "C",
    cpp: "C++",
    crystal: "Crystal",
    csharp: "C#",
    go: "Go",
    haskell: "Haskell",
    java: "Java",
    javascript: "JavaScript",
    matlab: "MATLAB",
    ocaml: "OCaml",
    pascal: "Pascal",
    php: "PHP",
    python: "Python",
    r: "R",
    ruby: "Ruby",
    rust: "Rust",
    sql: "SQL",
    typescript: "TypeScript"
  }.freeze

  belongs_to :user

  validates :code, presence: true
  validates :language, inclusion: { in: LANGUAGES.keys.map(&:to_s) }
  validates :user_id, uniqueness: { scope: %i[day challenge language], message: "can submit only 1 solution per language" }
end
