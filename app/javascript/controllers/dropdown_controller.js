import { Controller } from "@hotwired/stimulus"

// Dropdown controller
export default class extends Controller {
  static targets = [ "menu" ]
  
  connect() {
    this.isOpen = false
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener('click', this.clickOutsideHandler)
    // Close on escape key
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.clickOutsideHandler)
    document.removeEventListener('keydown', this.escapeHandler)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }
  
  open() {
    this.isOpen = true
    this.menuTarget.classList.remove('invisible', 'opacity-0', 'scale-95')
    this.menuTarget.classList.add('visible', 'opacity-100', 'scale-100')
  }
  
  close() {
    this.isOpen = false
    this.menuTarget.classList.add('invisible', 'opacity-0', 'scale-95')
    this.menuTarget.classList.remove('visible', 'opacity-100', 'scale-100')
  }

  clickOutside(event) {
    if (this.isOpen && !this.element.contains(event.target)) {
      this.close()
    }
  }
  
  handleEscape(event) {
    if (event.key === 'Escape' && this.isOpen) {
      this.close()
    }
  }
}