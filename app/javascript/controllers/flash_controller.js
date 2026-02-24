import { Controller } from "@hotwired/stimulus"

// Controla los flash messages (notice y alert).
// Se conecta automáticamente vía data-controller="flash".
export default class extends Controller {
  static targets = ["message"]

  connect() {
    // Auto-dismiss después de 5 segundos
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    // Limpiar timeout si el elemento se remueve antes
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s ease-out"
    this.element.style.opacity = "0"

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
