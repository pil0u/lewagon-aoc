import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["hours", "minutes", "seconds", "milliseconds", "party"]
  }

  static values = { refreshInterval: Number }

  connect () {
    this.updateClock()

    if (this.hasRefreshIntervalValue) {
      this.startRefreshing()
    }
  }

  updateClock () {
    const timeDiff = Date.parse('December 1 2021 00:00:00 EST') - (new Date()).getTime()

    if (timeDiff > 0) {
      const milliseconds = Math.floor(timeDiff % 1000)
      const seconds = Math.floor((timeDiff / 1000) % 60)
      const minutes = Math.floor((timeDiff / 1000 / 60) % 60)
      const hours = Math.floor((timeDiff / (1000 * 60 * 60)) % 24)

      this.hoursTarget.innerHTML = this.format(hours, 2)
      this.minutesTarget.innerHTML = this.format(minutes, 2)
      this.secondsTarget.innerHTML = this.format(seconds, 2)
      this.millisecondsTarget.innerHTML = this.format(milliseconds, 3)

      return
    }

    this.hoursTarget.innerHTML = "00"
    this.minutesTarget.innerHTML = "00"
    this.secondsTarget.innerHTML = "00"
    this.millisecondsTarget.innerHTML = "000"
    for (let t of this.partyTargets) {
      t.innerHTML = "🎉"
    }

    this.stopRefreshing()
  }

  startRefreshing () {
    this.refreshTimer = setInterval(() => {
      this.updateClock()
    }, this.refreshIntervalValue)
  }

  stopRefreshing () {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }

  format (integer, digits) {
    return new Intl.NumberFormat("en", { minimumIntegerDigits: digits }).format(integer)
  }
}
