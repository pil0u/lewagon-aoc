import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["codeBlock", "trigger"]

  connect() {
    // Hide the "show more" button if the code block is not truncated
    if (this.codeBlockTarget.scrollHeight <= this.codeBlockTarget.offsetHeight) {
        this.triggerTarget.classList.add("hidden")
    }
  }

  handleToggleExpandable() {
    const isExpanded = !this.codeBlockTarget.classList.toggle("truncated")
    this.triggerTarget.textContent = isExpanded ? "↑ Show less ↑" : "↓ Show more ↓"
    this.codeBlockTarget.scrollIntoView({ behavior: "smooth" })
  }
}
