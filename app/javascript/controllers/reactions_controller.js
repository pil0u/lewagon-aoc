import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter", "reaction"]

  static values = {
    snippetId: Number,
    vote: String
  }

  connect() {
    this.vote = JSON.parse(this.voteValue)
    this.#toggleBorder()
  }

  async handleToggleReaction(event) {
    event.preventDefault()

    const formData = new FormData(event.currentTarget.parentElement)
    const reaction = event.currentTarget.dataset.reactionType

    if (reaction === this.vote?.reaction_type) {
      await this.#deleteReaction(formData)
    } else if (this.vote) {
      await this.#updateReaction(formData)
    } else {
      await this.#createReaction(formData)
    }

    this.#toggleBorder()
  }

  #updateCounter(modifier) {
    const counter = this.counterTargets.find(span => span.dataset.reactionType === this.vote.reaction_type)
    counter.innerText = modifier + Number(counter.innerText)
  }

  #toggleBorder() {
    this.reactionTargets.forEach(reaction => {
      if (reaction.dataset.reactionType === this.vote?.reaction_type) {
        reaction.classList.add("border-aoc-green", "bg-aoc-green/20")
        reaction.classList.remove("border-aoc-gray-darker")
      } else {
        reaction.classList.add("border-aoc-gray-darker")
        reaction.classList.remove("border-aoc-green", "bg-aoc-green/20")
      }
    })
  }

  async #createReaction(body) {
    try {
      const response = await fetch(`/snippets/${this.snippetIdValue}/reactions`, {
        method: "POST",
        headers: {
          Accept: "application/json"
        },
        body
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.errors)
      }

      const data = await response.json()
      this.vote = data.reaction
      this.#updateCounter(1)
    } catch (error) {
      console.log(error)
    }
  }

  async #updateReaction(body) {
    try {
      const response = await fetch(`/reactions/${this.vote.id}`, {
        method: "PATCH",
        headers: {
          Accept: "application/json"
        },
        body
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.errors)
      }

      const data = await response.json()
      this.#updateCounter(-1)
      this.vote = data.reaction
      this.#updateCounter(1)
    } catch (error) {
      console.log(error)
    }
  }

  async #deleteReaction(body) {
    await fetch(`/reactions/${this.vote.id}`, {
      method: "DELETE",
      headers: {
        Accept: "application/json"
      },
      body
    })

    this.#updateCounter(-1)
    this.vote = null
  }
}
