import { Controller } from "@hotwired/stimulus"

// Handles hover + click for the 5-star rating widget.
// Usage:
//   data-controller="star-rating"
//   data-star-rating-value-value="3"   ← current persisted value (0 = unrated)
//
// Each star button:
//   data-star-rating-target="star"
//   data-value="1" (through 5)
export default class extends Controller {
  static targets = ["star", "input"]
  static values  = { value: { type: Number, default: 0 } }

  connect() {
    this.#render(this.valueValue)
  }

  highlight({ currentTarget }) {
    this.#render(parseInt(currentTarget.dataset.value))
  }

  reset() {
    this.#render(this.valueValue)
  }

  select({ currentTarget }) {
    const picked = parseInt(currentTarget.dataset.value)
    this.valueValue = picked
    if (this.hasInputTarget) {
      this.inputTarget.value = picked
    }
    this.#render(picked)
    // Auto-submit the surrounding form
    currentTarget.closest("form")?.requestSubmit()
  }

  #render(hovered) {
    this.starTargets.forEach((star) => {
      const v = parseInt(star.dataset.value)
      const filled = v <= hovered
      star.style.color  = filled ? "#f59e0b" : "#d1d5db"
      star.setAttribute("aria-checked", filled ? "true" : "false")
    })
  }
}
