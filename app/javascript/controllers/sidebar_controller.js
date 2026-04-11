import { Controller } from "@hotwired/stimulus"

// Drives the collapsible sidebar on mobile.
// Put data-controller="sidebar" on a wrapper that contains both the
// <aside data-sidebar-target="panel"> and the backdrop overlay.
export default class extends Controller {
  static targets = ["panel", "backdrop"]

  toggle() {
    const isOpen = this.panelTarget.dataset.open === "true"
    isOpen ? this.close() : this.open()
  }

  open() {
    this.panelTarget.dataset.open = "true"
    if (this.hasBackdropTarget) this.backdropTarget.style.display = "block"
    document.body.style.overflow = "hidden"
  }

  close() {
    this.panelTarget.dataset.open = "false"
    if (this.hasBackdropTarget) this.backdropTarget.style.display = "none"
    document.body.style.overflow = ""
  }
}
