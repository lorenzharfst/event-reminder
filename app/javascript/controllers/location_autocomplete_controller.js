import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]

  connect() {
    this._timer = null
    this._items = []
  }

  disconnect() {
    clearTimeout(this._timer)
  }

  onInput() {
    clearTimeout(this._timer)
    const query = this.inputTarget.value.trim()

    if (query.length < 3) {
      this._hide()
      return
    }

    this._timer = setTimeout(() => this._fetch(query), 300)
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.inputTarget.value = this._label(this._items[index])
    this._hide()
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) this._hide()
  }

  async _fetch(query) {
    try {
      const url = `https://nominatim.openstreetmap.org/search` +
        `?q=${encodeURIComponent(query)}&format=json&limit=5&addressdetails=1`
      const res = await fetch(url, { headers: { "Accept-Language": "en" } })
      this._items = await res.json()
      this._render()
    } catch {
      this._hide()
    }
  }

  _render() {
    if (!this._items.length) { this._hide(); return }

    this.dropdownTarget.innerHTML = this._items.map((item, i) => {
      const label = this._label(item)
      return `<button type="button"
                class="dropdown-item text-truncate"
                data-action="click->location-autocomplete#select"
                data-index="${i}"
                title="${label}">
                ${label}
              </button>`
    }).join("")

    this.dropdownTarget.classList.add("show")
  }

  _hide() {
    this.dropdownTarget.classList.remove("show")
    this.dropdownTarget.innerHTML = ""
  }

  // Build a short but unambiguous location label from Nominatim address components.
  _label(item) {
    const a = item.address || {}
    const city = a.city || a.town || a.village || a.hamlet || a.suburb || item.name
    const parts = [city, a.state, a.country].filter(Boolean)
    return parts.join(", ")
  }
}
