import { Controller } from "@hotwired/stimulus"

// Simple tabs: buttons with aria-controls matching panel ids.
export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { index: { type: Number, default: 0 } }

  connect() {
    this.show(this.indexValue)
  }

  select(event) {
    event.preventDefault()
    const tab = event.currentTarget
    const index = this.tabTargets.indexOf(tab)
    if (index >= 0) {
      this.show(index)
    } else {
      const id = tab.getAttribute("aria-controls")
      this.showById(id)
    }
  }

  show(index) {
    this.indexValue = index
    this.tabTargets.forEach((tab, i) => {
      const selected = i === index
      tab.setAttribute("aria-selected", selected ? "true" : "false")
      tab.classList.toggle("is-active", selected)
      tab.tabIndex = selected ? 0 : -1
    })
    this.panelTargets.forEach((panel, i) => {
      panel.hidden = i !== index
    })
  }

  showById(id) {
    if (!id) return
    const index = this.panelTargets.findIndex((p) => p.id === id)
    if (index >= 0) this.show(index)
  }
}
