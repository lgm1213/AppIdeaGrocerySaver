import { Controller } from "@hotwired/stimulus"

// Auto-dismisses flash messages after a delay
export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    this.timer = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.style.transition = "opacity 300ms ease, transform 300ms ease"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-0.5rem)"
    setTimeout(() => this.element.remove(), 320)
  }
}
