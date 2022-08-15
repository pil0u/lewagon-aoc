import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  now () {
    // For some reason, Chrome and Safari do not receive Devise's sign in
    // get requests if the button is disabled instantly. Thus a timeout.
    setTimeout(() => {
      this.element.disabled = true
    }, 50)
  }
}
