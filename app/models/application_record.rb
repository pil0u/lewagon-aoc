# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

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
end
