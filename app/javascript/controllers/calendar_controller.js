import { Controller } from "@hotwired/stimulus"

// Manages the weekly meal plan calendar:
// - opens/closes the recipe picker modal
// - drives the recipe_picker turbo-frame by updating its src
// - debounces search input
export default class extends Controller {
  static targets = ["recipeSearch", "slotLabel"]

  #currentDay     = null
  #currentSlot    = null
  #currentEntryId = null
  #mealPlanId     = null
  #filterTimer    = null

  connect() {
    this.#mealPlanId = this.element.dataset.mealPlanId
  }

  // ── Open picker ────────────────────────────────────────────────────────
  openPicker(event) {
    const btn = event.currentTarget
    this.#currentDay     = btn.dataset.day
    this.#currentSlot    = btn.dataset.slot
    this.#currentEntryId = btn.dataset.entryId || ""

    const dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    if (this.hasSlotLabelTarget) {
      this.slotLabelTarget.textContent =
        `${dayNames[this.#currentDay]} · ${this.#currentSlot.charAt(0).toUpperCase() + this.#currentSlot.slice(1)}`
    }

    if (this.hasRecipeSearchTarget) {
      this.recipeSearchTarget.value = ""
    }

    this.#updateFrame("")
    this.#showModal()
  }

  // ── Filter on search input (debounced 300 ms) ──────────────────────────
  filterRecipes(event) {
    const value = event.target.value
    clearTimeout(this.#filterTimer)
    this.#filterTimer = setTimeout(() => this.#updateFrame(value), 300)
  }

  // ── Private helpers ────────────────────────────────────────────────────
  #updateFrame(query) {
    const frame = document.getElementById("recipe_picker_list")
    if (!frame || !this.#mealPlanId || !this.#currentSlot) return
    frame.src = this.#pickerUrl(query)
  }

  #pickerUrl(query) {
    const url = new URL(
      `/app/meal_plans/${this.#mealPlanId}/recipe_picker`,
      window.location.origin
    )
    url.searchParams.set("slot",     this.#currentSlot)
    url.searchParams.set("day",      this.#currentDay)
    url.searchParams.set("entry_id", this.#currentEntryId)
    if (query) url.searchParams.set("q", query)
    return url.toString()
  }

  #showModal() {
    const modal = document.getElementById("recipe-picker-modal")
    if (modal) {
      modal.style.display = "block"
      document.body.style.overflow = "hidden"
      this.recipeSearchTarget?.focus()
    }
  }
}
