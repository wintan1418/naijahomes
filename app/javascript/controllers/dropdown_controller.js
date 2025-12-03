import { Controller } from "@hotwired/stimulus"

// Dropdown controller
export default class extends Controller {
  static targets = [ "menu" ]

  connect() {
    // Close dropdown when clicking outside
    this.clickOutside = this.clickOutside.bind(this)
    document.addEventListener('click', this.clickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.clickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('invisible')
    this.menuTarget.classList.toggle('opacity-0')
    this.menuTarget.classList.toggle('scale-95')
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('invisible')
      this.menuTarget.classList.add('opacity-0')
      this.menuTarget.classList.add('scale-95')
    }
  }
}