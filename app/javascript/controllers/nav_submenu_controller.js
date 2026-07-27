import { Controller } from "@hotwired/stimulus"

// Expand/collapse sidebar company submenu.
export default class extends Controller {
  static targets = ["panel", "button"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    this.sync()
  }

  toggle() {
    this.openValue = !this.openValue
    this.sync()
  }

  openValueChanged() {
    this.sync()
  }

  sync() {
    if (this.hasPanelTarget) {
      this.panelTarget.hidden = !this.openValue
    }
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", this.openValue ? "true" : "false")
      this.buttonTarget.classList.toggle("is-open", this.openValue)
    }
  }
}
