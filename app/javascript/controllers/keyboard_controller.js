import { Controller } from "@hotwired/stimulus"

// Global shortcuts: / focuses search, j/k cycle [data-keyboard-item], ? toggles hints.
export default class extends Controller {
  static targets = ["search", "hints", "item"]
  static values = { index: { type: Number, default: -1 } }

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown(event) {
    if (this.isTyping(event)) return

    switch (event.key) {
      case "/":
        event.preventDefault()
        this.focusSearch()
        break
      case "j":
      case "J":
        event.preventDefault()
        this.move(1)
        break
      case "k":
      case "K":
        event.preventDefault()
        this.move(-1)
        break
      case "?":
        if (this.hasHintsTarget) {
          this.hintsTarget.hidden = !this.hintsTarget.hidden
        }
        break
      default:
        break
    }
  }

  focusSearch() {
    const input = this.hasSearchTarget
      ? this.searchTarget
      : document.querySelector("[data-keyboard-target='search'], #global-search")
    if (input) {
      input.focus()
      input.select?.()
    }
  }

  move(delta) {
    const items = this.items()
    if (!items.length) return

    let next = this.indexValue + delta
    if (next < 0) next = items.length - 1
    if (next >= items.length) next = 0
    this.indexValue = next

    items.forEach((el, i) => el.classList.toggle("is-keyboard-focus", i === next))
    const current = items[next]
    current.focus?.()
    current.scrollIntoView({ block: "nearest", behavior: "smooth" })
  }

  items() {
    if (this.hasItemTarget) return this.itemTargets
    return Array.from(document.querySelectorAll("[data-keyboard-item]"))
  }

  isTyping(event) {
    const tag = event.target?.tagName
    return event.target?.isContentEditable ||
      tag === "INPUT" ||
      tag === "TEXTAREA" ||
      tag === "SELECT"
  }
}
