import { Controller } from "@hotwired/stimulus"

// Expand/collapse panels. Set data-accordion-exclusive="true" for one-open mode.
export default class extends Controller {
  static targets = ["panel", "trigger"]

  connect() {
    this.panels().forEach((panel) => {
      if (panel.dataset.open === "true") {
        panel.hidden = false
      } else if (!panel.hasAttribute("hidden")) {
        panel.hidden = true
      }
    })

    this.triggers().forEach((trigger) => {
      const panel = this.panelFor(trigger)
      const open = panel && !panel.hidden
      trigger.setAttribute("aria-expanded", open ? "true" : "false")
      trigger.classList.toggle("is-open", open)
    })
  }

  toggle(event) {
    const trigger = event.currentTarget
    const panel = this.panelFor(trigger)
    if (!panel) return

    const willOpen = panel.hidden

    if (this.element.dataset.accordionExclusive === "true" && willOpen) {
      this.panels().forEach((p) => {
        p.hidden = true
      })
      this.triggers().forEach((t) => {
        t.setAttribute("aria-expanded", "false")
        t.classList.remove("is-open")
      })
    }

    panel.hidden = !willOpen
    trigger.setAttribute("aria-expanded", willOpen ? "true" : "false")
    trigger.classList.toggle("is-open", willOpen)
  }

  panelFor(trigger) {
    const panelId = trigger.getAttribute("aria-controls")
    if (panelId) {
      return document.getElementById(panelId) ||
        this.element.querySelector(`#${CSS.escape(panelId)}`)
    }
    return trigger.nextElementSibling
  }

  panels() {
    if (this.hasPanelTarget) return this.panelTargets
    return Array.from(this.element.querySelectorAll("[data-accordion-target='panel']"))
  }

  triggers() {
    if (this.hasTriggerTarget) return this.triggerTargets
    return Array.from(this.element.querySelectorAll("[data-accordion-target='trigger']"))
  }
}
