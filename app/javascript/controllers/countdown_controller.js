import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds", "milliseconds", "code"]
  static values = { launchDate: String }

  connect() {
    if (new Date() < new Date(this.launchDateValue)) {
      setInterval(() => this.#updateClock(), 23)
    }
  }

  #updateClock() {
    const timeDiff = new Date(this.launchDateValue) - Date.now()

    if (timeDiff > 0) {
      this.daysTarget.innerHTML = this.#format(Math.floor((timeDiff / (1000 * 60 * 60 * 24))), 2)
      this.hoursTarget.innerHTML = this.#format(Math.floor((timeDiff / (1000 * 60 * 60)) % 24), 2)
      this.minutesTarget.innerHTML = this.#format(Math.floor((timeDiff / 1000 / 60) % 60), 2)
      this.secondsTarget.innerHTML = this.#format(Math.floor((timeDiff / 1000) % 60), 2)
      this.millisecondsTarget.innerHTML = this.#format(Math.floor(timeDiff % 1000), 3)

      if (Math.floor(timeDiff % 1000) % 100 == 0) {
        this.codeTarget.classList.remove("hidden")
      } else {
        this.codeTarget.classList.add("hidden")
      }

      return
    }

    this.millisecondsTarget.innerHTML = "000"
    
    // Reload the page only once
    if (!this.hasReloaded) {
      this.hasReloaded = true
      setTimeout(() => location.reload(), 500)
    }
  }

  #format(integer, digits) {
    return integer.toString().padStart(digits, "0")
  }
}
