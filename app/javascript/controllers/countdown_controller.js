import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["days", "hours", "minutes", "seconds", "milliseconds", "code"]
  }

  static get values () {
    return { refreshInterval: Number, launchDate: String }
  }

  connect () {
    console.log(this.launchDateValue)
    if (new Date() < new Date(this.launchDateValue)) {
      this.startRefreshing()
    }
  }

  updateClock () {
    const timeDiff = new Date(this.launchDateValue) - (new Date()).getTime()

    if (timeDiff > 0) {
      this.daysTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60 * 24))), 2)
      this.hoursTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60)) % 24), 2)
      this.minutesTarget.innerHTML = this.format(Math.floor((timeDiff / 1000 / 60) % 60), 2)
      this.secondsTarget.innerHTML = this.format(Math.floor((timeDiff / 1000) % 60), 2)
      this.millisecondsTarget.innerHTML = this.format(Math.floor(timeDiff % 1000), 3)

      if (Math.floor(timeDiff % 1000) % 100 == 0) {
        this.codeTarget.classList.remove("hidden")
      } else {
        this.codeTarget.classList.add("hidden")
      }

      return
    }

    this.millisecondsTarget.innerHTML = "000"

    setInterval(() => {
      location.reload()
    }, 500)
  }

  startRefreshing () {
    this.refreshTimer = setInterval(() => {
      this.updateClock()
    }, this.refreshIntervalValue)
  }

  format (integer, digits) {
    return integer.toString().padStart(digits, "0")
  }
}
