import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feedback"]
  static values = { content: String }

  copy() {
    navigator.clipboard.writeText(this.contentValue)
    this.toggleFeedback()
    setTimeout(() => this.toggleFeedback(), 1500)
  }

  toggleFeedback() {
    this.feedbackTarget.classList.toggle("hidden")
    this.feedbackTarget.classList.toggle("animate-feedback")
  }
}
