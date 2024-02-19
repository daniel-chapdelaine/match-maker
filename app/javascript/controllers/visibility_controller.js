import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  toggleTargets(event) {
    const el = document.getElementById(`hideable-${event.params.index}`)
    el.hidden = !el.hidden
  }
}