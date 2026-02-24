import { Controller } from "@hotwired/stimulus"

// Controla el menú hamburgesa del navbar en móvil.
export default class extends Controller {
    static targets = ["menu"]

    toggle() {
        this.menuTarget.classList.toggle("hidden")
    }

    // Cerrar menú al hacer clic en un link (navegación con Turbo)
    disconnect() {
        if (this.hasMenuTarget) {
            this.menuTarget.classList.add("hidden")
        }
    }
}
