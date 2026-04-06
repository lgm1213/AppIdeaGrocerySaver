import { Controller } from "@hotwired/stimulus"

// Manages the onboarding wizard:
// - Chip (multi-select) toggle for dietary restrictions and cuisines
// - Household size selector
// - Budget slider live preview
// - Skill/complexity pill selectors
export default class extends Controller {
  static targets = [
    "chip",
    "chipInput",
    "sizeOption",
    "sizeInput",
    "skillOption",
    "skillInput",
    "complexityOption",
    "complexityInput",
    "budgetSlider",
    "budgetDisplay",
    "storeInput",
    "submitBtn"
  ]

  static values = {
    selectedDietary: Array,
    selectedCuisines: Array
  }

  connect() {
    this.syncChipStates()
    this.syncSingleSelectors()
    if (this.hasBudgetSliderTarget) {
      this.updateBudgetDisplay()
    }
  }

  // ── Chip (multi-select) toggle ──────────────────────────────────────────

  toggleChip(event) {
    const chip = event.currentTarget
    const value = chip.dataset.value
    const group = chip.dataset.group  // "dietary" | "cuisine"
    const isActive = chip.classList.contains("chip-active")

    if (isActive) {
      chip.classList.replace("chip-active", "chip-inactive")
    } else {
      chip.classList.replace("chip-inactive", "chip-active")
    }

    this.syncHiddenChipInputs(group)
  }

  syncHiddenChipInputs(group) {
    // Remove all existing hidden inputs for this group
    this.element.querySelectorAll(`input[data-chip-group="${group}"]`).forEach(el => el.remove())

    // Re-create from active chips
    const activeChips = this.element.querySelectorAll(`.chip-active[data-group="${group}"]`)
    const form = this.element.closest("form")
    if (!form) return

    activeChips.forEach(chip => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = group === "dietary"
        ? "user_preference[dietary_restrictions][]"
        : "user_preference[preferred_cuisines][]"
      input.value = chip.dataset.value
      input.dataset.chipGroup = group
      form.appendChild(input)
    })

    // If none active, still send an empty array sentinel so Rails clears the column
    if (activeChips.length === 0) {
      const sentinel = document.createElement("input")
      sentinel.type = "hidden"
      sentinel.name = group === "dietary"
        ? "user_preference[dietary_restrictions][]"
        : "user_preference[preferred_cuisines][]"
      sentinel.value = ""
      sentinel.dataset.chipGroup = group
      form.appendChild(sentinel)
    }
  }

  syncChipStates() {
    // Called on connect — ensure chip visual states match any pre-selected hidden inputs
    const form = this.element.closest("form")
    if (!form) return

    ;["dietary", "cuisine"].forEach(group => {
      const activeValues = Array.from(
        form.querySelectorAll(`input[data-chip-group="${group}"]`)
      ).map(i => i.value).filter(Boolean)

      this.element.querySelectorAll(`.chip[data-group="${group}"]`).forEach(chip => {
        if (activeValues.includes(chip.dataset.value)) {
          chip.classList.replace("chip-inactive", "chip-active")
        }
      })
    })
  }

  // ── Household size single-select ────────────────────────────────────────

  selectSize(event) {
    const selected = event.currentTarget
    const value = selected.dataset.value

    // Update visuals
    this.sizeOptionTargets.forEach(opt => {
      const isSelected = opt.dataset.value === value
      opt.style.backgroundColor = isSelected ? "#1a7425" : "#e9eaca"
      opt.style.color = isSelected ? "white" : "#646652"
    })

    // Update hidden input
    if (this.hasSizeInputTarget) {
      this.sizeInputTarget.value = value
    }
  }

  // ── Skill / complexity single-select pill ───────────────────────────────

  selectSkill(event) {
    this.#activatePill(event.currentTarget, this.skillOptionTargets, this.skillInputTarget)
  }

  selectComplexity(event) {
    this.#activatePill(event.currentTarget, this.complexityOptionTargets, this.complexityInputTarget)
  }

  #activatePill(selected, allTargets, hiddenInput) {
    const value = selected.dataset.value

    allTargets.forEach(opt => {
      const isSelected = opt.dataset.value === value
      opt.classList.toggle("chip-active", isSelected)
      opt.classList.toggle("chip-inactive", !isSelected)
    })

    if (hiddenInput) hiddenInput.value = value
  }

  syncSingleSelectors() {
    // Restore visual state from hidden input values on page load
    if (this.hasSizeInputTarget && this.hasSizeOptionTarget) {
      const current = this.sizeInputTarget.value
      this.sizeOptionTargets.forEach(opt => {
        const isSelected = opt.dataset.value === current
        opt.style.backgroundColor = isSelected ? "#1a7425" : "#e9eaca"
        opt.style.color = isSelected ? "white" : "#646652"
      })
    }

    if (this.hasSkillInputTarget && this.hasSkillOptionTarget) {
      const current = this.skillInputTarget.value
      this.skillOptionTargets.forEach(opt => {
        const isSelected = opt.dataset.value === current
        opt.classList.toggle("chip-active", isSelected)
        opt.classList.toggle("chip-inactive", !isSelected)
      })
    }

    if (this.hasComplexityInputTarget && this.hasComplexityOptionTarget) {
      const current = this.complexityInputTarget.value
      this.complexityOptionTargets.forEach(opt => {
        const isSelected = opt.dataset.value === current
        opt.classList.toggle("chip-active", isSelected)
        opt.classList.toggle("chip-inactive", !isSelected)
      })
    }
  }

  // ── Budget slider ────────────────────────────────────────────────────────

  updateBudgetDisplay() {
    if (!this.hasBudgetSliderTarget || !this.hasBudgetDisplayTarget) return
    const value = parseInt(this.budgetSliderTarget.value, 10)
    this.budgetDisplayTarget.textContent = `$${value}`
  }

  // ── Budget presets ───────────────────────────────────────────────────────

  setBudgetPreset(event) {
    const preset = parseInt(event.currentTarget.dataset.preset, 10)
    if (!this.hasBudgetSliderTarget) return
    this.budgetSliderTarget.value = preset
    this.updateBudgetDisplay()
    this.#updateSliderGradient(preset)
  }

  budgetSliderChanged() {
    const value = parseInt(this.budgetSliderTarget.value, 10)
    this.updateBudgetDisplay()
    this.#updateSliderGradient(value)
  }

  #updateSliderGradient(value) {
    const pct = Math.min((value / 600) * 100, 100).toFixed(0)
    this.budgetSliderTarget.style.background =
      `linear-gradient(to right, #1a7425 0%, #1a7425 ${pct}%, #e9eaca ${pct}%, #e9eaca 100%)`
  }

  // ── Store selector ───────────────────────────────────────────────────────

  selectStore(event) {
    const btn = event.currentTarget
    const store = btn.dataset.store

    this.element.querySelectorAll("[data-store]").forEach(b => {
      b.classList.toggle("chip-active", b.dataset.store === store)
      b.classList.toggle("chip-inactive", b.dataset.store !== store)
    })

    if (this.hasStoreInputTarget) this.storeInputTarget.value = store
  }

  storeTyped(event) {
    const value = event.target.value.trim()
    // Deactivate chip buttons when typing custom store
    this.element.querySelectorAll("[data-store]").forEach(b => {
      b.classList.replace("chip-active", "chip-inactive")
    })
    if (this.hasStoreInputTarget) this.storeInputTarget.value = value
  }

  // ── Flash auto-dismiss ───────────────────────────────────────────────────

  // (handled by flash_controller.js)
}
