import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["days", "hours", "minutes", "seconds", "milliseconds"]
  }

  static get values () {
    return { refreshInterval: Number }
  }

  connect () {
    if (new Date() < Date.parse('November 10 2022 11:30:00 UTC')) {
      this.startRefreshing()
    }
  }

  updateClock () {
    const timeDiff = Date.parse('November 10 2022 11:30:00 UTC') - (new Date()).getTime()

    if (timeDiff > 0) {
      this.daysTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60 * 24))), 2)
      this.hoursTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60)) % 24), 2)
      this.minutesTarget.innerHTML = this.format(Math.floor((timeDiff / 1000 / 60) % 60), 2)
      this.secondsTarget.innerHTML = this.format(Math.floor((timeDiff / 1000) % 60), 2)
      this.millisecondsTarget.innerHTML = this.format(Math.floor(timeDiff % 1000), 3)

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
    return new Intl.NumberFormat("en", { minimumIntegerDigits: digits }).format(integer)
  }
}
