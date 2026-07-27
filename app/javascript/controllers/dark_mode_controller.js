import { Controller } from "@hotwired/stimulus"

const SUN = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"></path></svg>`
const MOON = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 14.5A8.5 8.5 0 0 1 9.5 3 7 7 0 1 0 21 14.5z"></path></svg>`

// Persists theme in localStorage and syncs html class + data-theme.
export default class extends Controller {
  static targets = ["label", "icon"]

  connect() {
    this.apply(this.storedTheme())
  }

  toggle() {
    const next = this.isDark() ? "light" : "dark"
    this.apply(next)
    localStorage.setItem("bf-theme", next)
  }

  apply(theme) {
    const dark = theme !== "light"
    const root = document.documentElement
    root.classList.toggle("dark", dark)
    root.classList.toggle("light", !dark)
    root.setAttribute("data-theme", dark ? "dark" : "light")
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = dark ? "Light" : "Dark"
    }
    if (this.hasIconTarget) {
      this.iconTarget.innerHTML = dark ? SUN : MOON
    }
  }

  isDark() {
    return document.documentElement.classList.contains("dark") ||
      document.documentElement.getAttribute("data-theme") === "dark"
  }

  storedTheme() {
    return localStorage.getItem("bf-theme") || "dark"
  }
}
