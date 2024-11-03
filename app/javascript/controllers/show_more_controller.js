import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["codeBlock", "button"]

    connect() {
        // Hide the button if the code block is not truncated
        if (this.codeBlockTarget.scrollHeight <= this.codeBlockTarget.offsetHeight) {
            this.buttonTarget.classList.add("hidden")
        }
    }

    toggle() {
        const isExpanded = !this.codeBlockTarget.classList.toggle("truncated")
        this.buttonTarget.textContent = isExpanded ? "↑ Show less ↑" : "↓ Show more ↓"

        this.codeBlockTarget.scrollIntoView({ behavior: "smooth" })
    }
}
