import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets () {
    return ["days", "hours", "minutes", "seconds", "milliseconds", "code"]
  }

  static get values () {
    return { refreshInterval: Number }
  }

  connect () {
    if (new Date() < Date.parse('October 11 2022 00:07:00 UTC')) {
      this.startRefreshing()
    }
  }

  updateClock () {
    const timeDiff = Date.parse('October 11 2022 00:07:00 UTC') - (new Date()).getTime()

    if (timeDiff > 0) {
      this.daysTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60 * 24))), 3)
      this.hoursTarget.innerHTML = this.format(Math.floor((timeDiff / (1000 * 60 * 60)) % 24), 3)
      this.minutesTarget.innerHTML = this.format(Math.floor((timeDiff / 1000 / 60) % 60), 4)
      this.secondsTarget.innerHTML = this.format(Math.floor((timeDiff / 1000) % 60), 4)
      this.millisecondsTarget.innerHTML = this.format(Math.floor(timeDiff % 1000), 7)

      this.encode()

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
    return Number(integer).toString(3).padStart(digits, '0')
  }

  encode () {
    const raw_groups = `
      53454E44205448452053
      554D204F462054484520
      46495253542031204D49
      4C4C494F4E2044454349
      4D414C53204F46205049
      20544F2050494C4F5520
      544F2047455420524557
      41524420202020202020
    `.replace(/\s/g, '').match(/.{2}/g)

    const groups = []
    raw_groups.forEach(e => groups.push(
      (parseInt(e, 16) * parseInt(this.minutesTarget.innerHTML, 3)).toString(3)
    ))

    this.codeTarget.innerHTML = groups.join(" ")
  }
}
