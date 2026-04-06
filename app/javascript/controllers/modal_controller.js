import { Controller } from "@hotwired/stimulus"

// Generic modal open/close.
// Add data-controller="modal" to the modal wrapper element.
export default class extends Controller {
  connect() {
    this.handleKeydown = this.#onKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  close() {
    this.element.style.display = "none"
    document.body.style.overflow = ""
  }

  #onKeydown(event) {
    if (event.key === "Escape" && this.element.style.display !== "none") {
      this.close()
    }
  }
}
