import { Controller } from "@hotwired/stimulus"

// Mobile sidebar open/close for app shell.
export default class extends Controller {
  static targets = ["shell"]

  open() {
    this.shellEl().classList.add("sidebar-open")
  }

  close() {
    this.shellEl().classList.remove("sidebar-open")
  }

  toggle() {
    this.shellEl().classList.toggle("sidebar-open")
  }

  shellEl() {
    return this.hasShellTarget ? this.shellTarget : this.element
  }
}
