import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["checkbox"]
  }

  static get values () {
    return { message: String }
  }

  ping () {
    if (this.checkboxTarget.checked) {
      confirm(this.messageValue) // eslint-disable-line no-alert
    }
  }
}
