import { Controller } from "@hotwired/stimulus"

// Periodically reloads a turbo-frame by fetching its src.
// Usage: data-controller="poll" data-poll-src-value="/path" data-poll-interval-value="3000"
export default class extends Controller {
  static values = {
    src:      String,
    interval: { type: Number, default: 3000 }
  }

  connect() {
    this.#schedule()
  }

  disconnect() {
    clearTimeout(this.#timer)
  }

  #timer = null

  #schedule() {
    this.#timer = setTimeout(() => this.#refresh(), this.intervalValue)
  }

  async #refresh() {
    try {
      const frame = document.getElementById("job_activity")
      if (frame) {
        frame.src = this.srcValue
        await frame.loaded
      }
    } finally {
      this.#schedule()
    }
  }
}
