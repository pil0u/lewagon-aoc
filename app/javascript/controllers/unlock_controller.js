import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["checkbox", "button"]
  }

  connect () {
    this.toggle()
  }

  toggle () {
    this.buttonTarget.disabled = !this.checkboxTarget.checked
  }
}
