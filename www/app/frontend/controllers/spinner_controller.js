import { Controller } from "@hotwired/stimulus"

const spinnerCharacters = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

export default class extends Controller {
  connect() {
    this.currentIndex = 0

    this.onInterval(() => {
      this.currentIndex = (this.currentIndex + 1) % spinnerCharacters.length
      this.setCurrentCharacter()
    }, 60)
  }

  setCurrentCharacter() {
    this.element.textContent = spinnerCharacters[this.currentIndex]
  }

  onInterval(callback, milliseconds) {
    const interval = setInterval(callback, milliseconds)
  }
}
