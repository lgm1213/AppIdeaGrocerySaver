import { Controller } from "@hotwired/stimulus"

// Shows slot action buttons on hover/focus within the card.
export default class extends Controller {
  static targets = ["actions"]

  mouseenter() {
    if (this.hasActionsTarget) {
      this.actionsTarget.style.display = "flex"
    }
  }

  mouseleave() {
    if (this.hasActionsTarget) {
      this.actionsTarget.style.display = "none"
    }
  }

  focusin() {
    if (this.hasActionsTarget) {
      this.actionsTarget.style.display = "flex"
    }
  }

  focusout(event) {
    if (!this.element.contains(event.relatedTarget) && this.hasActionsTarget) {
      this.actionsTarget.style.display = "none"
    }
  }
}
