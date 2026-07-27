import { Controller } from "@hotwired/stimulus"

// Client-side list filtering via data-filter-key / data-filter-value on items.
export default class extends Controller {
  static targets = ["item", "chip", "empty", "count", "query"]
  static values = { active: { type: Object, default: {} } }

  connect() {
    this.apply()
  }

  setFilter(event) {
    const chip = event.currentTarget
    const key = chip.dataset.filterKey
    const value = chip.dataset.filterValue
    if (!key) return

    const next = { ...this.activeValue }
    if (next[key] === value) {
      delete next[key]
    } else {
      next[key] = value
    }
    this.activeValue = next
    this.syncChips()
    this.apply()
  }

  clear() {
    this.activeValue = {}
    if (this.hasQueryTarget) this.queryTarget.value = ""
    this.syncChips()
    this.apply()
  }

  search() {
    this.apply()
  }

  syncChips() {
    if (!this.hasChipTarget) return
    this.chipTargets.forEach((chip) => {
      const key = chip.dataset.filterKey
      const value = chip.dataset.filterValue
      const active = this.activeValue[key] === value
      chip.classList.toggle("is-active", active)
      chip.setAttribute("aria-pressed", active ? "true" : "false")
    })
  }

  apply() {
    const q = this.hasQueryTarget ? this.queryTarget.value.trim().toLowerCase() : ""
    const filters = this.activeValue
    let visible = 0

    this.itemTargets.forEach((item) => {
      let show = true

      Object.entries(filters).forEach(([key, value]) => {
        if (!value) return
        const attr = item.dataset[`filter${this.pascal(key)}`] || item.getAttribute(`data-filter-${key}`)
        if (attr == null || attr.toString().toLowerCase() !== value.toString().toLowerCase()) {
          show = false
        }
      })

      if (show && q) {
        const hay = (item.dataset.filterText || item.textContent || "").toLowerCase()
        if (!hay.includes(q)) show = false
      }

      item.hidden = !show
      if (show) visible += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible > 0
    if (this.hasCountTarget) this.countTarget.textContent = String(visible)
  }

  pascal(str) {
    return str.split(/[-_]/).map((s) => s.charAt(0).toUpperCase() + s.slice(1)).join("")
  }
}
