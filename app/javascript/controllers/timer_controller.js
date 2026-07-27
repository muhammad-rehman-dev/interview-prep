import { Controller } from "@hotwired/stimulus"

// Countdown / stopwatch for mock sessions. data-timer-seconds-value, data-timer-mode-value="down|up"
export default class extends Controller {
  static targets = ["display"]
  static values = {
    seconds: { type: Number, default: 0 },
    remaining: { type: Number, default: 0 },
    mode: { type: String, default: "down" },
    running: { type: Boolean, default: false }
  }

  connect() {
    this.remainingValue = this.secondsValue
    this.render()
  }

  disconnect() {
    this.stop()
  }

  start() {
    if (this.runningValue) return
    this.runningValue = true
    this.tick()
    this.interval = window.setInterval(() => this.tick(), 1000)
  }

  pause() {
    this.runningValue = false
    if (this.interval) window.clearInterval(this.interval)
  }

  stop() {
    this.pause()
  }

  reset() {
    this.pause()
    this.remainingValue = this.secondsValue
    this.elapsed = 0
    this.render()
  }

  toggle() {
    this.runningValue ? this.pause() : this.start()
  }

  tick() {
    if (this.modeValue === "up") {
      this.elapsed = (this.elapsed || 0) + 1
      this.render(this.elapsed)
      return
    }

    if (this.remainingValue <= 0) {
      this.pause()
      this.render(0)
      this.dispatch("finished")
      return
    }

    this.remainingValue -= 1
    this.render(this.remainingValue)
  }

  render(value = this.remainingValue) {
    if (!this.hasDisplayTarget) return
    const total = Math.max(0, value)
    const m = Math.floor(total / 60)
    const s = total % 60
    this.displayTarget.textContent = `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
  }
}
