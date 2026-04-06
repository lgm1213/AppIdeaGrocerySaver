import { Controller } from "@hotwired/stimulus"

// Manages the week selection chips in the meal generator.
// Exactly one chip is active at a time; clicking activates it and updates
// the hidden radio input so the form submits the right week_start value.
export default class extends Controller {
  static targets = ["chip", "radio"]

  select(event) {
    const clicked = event.currentTarget
    const index   = clicked.dataset.index

    this.chipTargets.forEach((chip, i) => {
      chip.classList.toggle("chip-active",   String(i) === index)
      chip.classList.toggle("chip-inactive", String(i) !== index)
    })

    this.radioTargets.forEach((radio, i) => {
      radio.checked = String(i) === index
    })
  }
}
