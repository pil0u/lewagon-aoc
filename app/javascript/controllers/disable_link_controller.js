import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  now () {
    this.element.disabled = true
  }
}
