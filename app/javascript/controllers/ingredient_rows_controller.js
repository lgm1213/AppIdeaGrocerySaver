import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "row", "template"]

  addRow() {
    const index = this.rowTargets.length
    const html  = this.templateTarget.innerHTML.replaceAll("__INDEX__", index)

    const wrapper = document.createElement("div")
    wrapper.innerHTML = html
    this.listTarget.appendChild(wrapper.firstElementChild)
  }

  removeRow(event) {
    const row = event.currentTarget.closest("[data-ingredient-rows-target='row']")
    if (this.rowTargets.length > 1) {
      row.remove()
      this._reindex()
    } else {
      // Keep at least one row — just clear its values instead
      row.querySelectorAll("input, select").forEach(el => { el.value = "" })
    }
  }

  _reindex() {
    this.rowTargets.forEach((row, i) => {
      row.querySelectorAll("[name]").forEach(el => {
        el.name = el.name.replace(/\[\d+\]/, `[${i}]`)
      })
    })
  }
}
