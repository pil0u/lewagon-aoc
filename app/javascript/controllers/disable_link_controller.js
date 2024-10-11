import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  now() {
    requestAnimationFrame(() => this.element.disabled = true)
  }
}
