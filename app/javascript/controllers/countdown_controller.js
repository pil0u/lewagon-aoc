import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds", "milliseconds", "enigma"]
  static values = { launchDate: String }

  connect() {
    if (new Date() < new Date(this.launchDateValue)) {
      this.interval = setInterval(() => this.#updateClock(), 23)
    }
  }

  #format(digits, integer) {
    return integer.toString().padStart(digits, "0")
  }

  #updateClock() {
    const timeDiff = new Date(this.launchDateValue) - Date.now()

    // While the countdown is running

    if (timeDiff > 0) {
      // Update the values of the timer
      this.daysTarget.innerHTML = this.#format(2, Math.floor((timeDiff / (1000 * 60 * 60 * 24))))
      this.hoursTarget.innerHTML = this.#format(2, Math.floor((timeDiff / (1000 * 60 * 60)) % 24))
      this.minutesTarget.innerHTML = this.#format(2, Math.floor((timeDiff / 1000 / 60) % 60))
      this.secondsTarget.innerHTML = this.#format(2, Math.floor((timeDiff / 1000) % 60))
      this.millisecondsTarget.innerHTML = this.#format(3, Math.floor(timeDiff % 1000))

      // Make the enigma blink
      this.enigmaTarget.classList.toggle("hidden", Math.floor(timeDiff % 1000) % 100 !== 0);

      return
    }

    // When the countdown is over
    clearInterval(this.interval)

    // Force the timer to 0
    this.millisecondsTarget.innerHTML = "000"

    // Reload the page
    setTimeout(() => location.reload(), 500)
  }
}
