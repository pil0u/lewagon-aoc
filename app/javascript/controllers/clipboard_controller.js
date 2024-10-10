import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    content: String
  }

  static targets = ["feedback"]

  copy() {
    navigator.clipboard.writeText(this.contentValue)
    this.showFeedback()
  }

  showFeedback() {
    this.feedbackTarget.classList.remove("hidden")
    this.feedbackTarget.classList.add("animate-feedback")
    
    setTimeout(() => {
      this.feedbackTarget.classList.remove("animate-feedback")
      this.feedbackTarget.classList.add("hidden")
    }, 1500)
  }
}
