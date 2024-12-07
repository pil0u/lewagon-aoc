import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    message: String,
  }

  handleSubmit(event) {
    event.preventDefault()
    if (this.messageValue && !confirm(this.messageValue)) { return }

    const newTab = window.open("", "_blank")
    const form = event.currentTarget.parentElement.cloneNode(true)
    form.style.display = "none"
    newTab.document.body.appendChild(form)
    form.submit()
  }
}
