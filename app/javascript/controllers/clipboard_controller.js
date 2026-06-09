import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]
  static values = { successLabel: String }

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
    const original = this.buttonTarget.textContent.trim()
    this.buttonTarget.textContent = this.successLabelValue
    setTimeout(() => this.buttonTarget.textContent = original, 2000)
  }
}
