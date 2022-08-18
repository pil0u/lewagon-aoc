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
        alert(this.messageValue)
      }
    }
}
