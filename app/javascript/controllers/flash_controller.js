import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect () {
    this.element.setAttribute(
      "style",
      `transition: 1s; transform:translate(-30.5rem, 0);`
    )

    setTimeout(() => {
      this.close()
    }, 4000)
  }

  close () {
    this.element.setAttribute(
      "style",
      `transition: 1s; transform:translate(-2rem, 0);`
    )
    setTimeout(() => {
      this.element.remove()
    }, 1000)
  }
}
