# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

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
end
