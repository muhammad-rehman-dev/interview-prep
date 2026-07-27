import { Controller } from "@hotwired/stimulus"

// Flip card; Space or click toggles. data-action="click->flashcard#flip"
export default class extends Controller {
  static targets = ["card"]
  static classes = ["flipped"]

  connect() {
    this.flipped = false
  }

  flip() {
    this.apply(!this.flipped)
  }

  showFront() {
    this.apply(false)
  }

  showBack() {
    this.apply(true)
  }

  apply(flipped) {
    this.flipped = flipped
    const el = this.hasCardTarget ? this.cardTarget : this.element
    el.classList.toggle("is-flipped", this.flipped)
    if (this.hasFlippedClass) {
      el.classList.toggle(this.flippedClass, this.flipped)
    }
    el.setAttribute("aria-pressed", this.flipped ? "true" : "false")
  }
}
