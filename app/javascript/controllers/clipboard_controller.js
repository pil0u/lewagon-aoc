import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }
  static targets = ["feedback"]

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
