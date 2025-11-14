import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    Turbo.navigator.submitForm(this.element);
  }
}
