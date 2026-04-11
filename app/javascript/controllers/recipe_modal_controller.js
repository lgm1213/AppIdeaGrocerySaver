import { Controller } from "@hotwired/stimulus"

// Global recipe quick-view modal.
// Place data-controller="recipe-modal" on <body> so any element anywhere
// can trigger it via:
//   data-action="click->recipe-modal#open"
//   data-recipe-modal-recipe-id-param="<uuid>"
export default class extends Controller {
  static values = { baseUrl: { type: String, default: "/app/recipes" } }

  open(event) {
    const recipeId = event.params.recipeId
    const frame    = document.getElementById("recipe_quick_view")
    const modal    = document.getElementById("recipe-quick-view-modal")

    if (frame) frame.src = `${this.baseUrlValue}/${recipeId}`
    if (modal) {
      modal.style.display = "block"
      document.body.style.overflow = "hidden"
    }
  }

  close() {
    const modal = document.getElementById("recipe-quick-view-modal")
    if (modal) modal.style.display = "none"
    document.body.style.overflow = ""
  }
}
