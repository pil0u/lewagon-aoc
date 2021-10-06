import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["answer", "block"]
  }

  connect () {
    this.answerTarget.classList.add("hidden")
  }

  toggle () {
    if (this.answerTarget.classList.contains("hidden")) {
      this.answerTarget.classList.remove("hidden")
      this.blockTarget.classList.add("border", "border-aoc-gray-darker")
    } else {
      this.answerTarget.classList.add("hidden")
      this.blockTarget.classList.remove("border", "border-aoc-gray-darker")
    }
  }
}
