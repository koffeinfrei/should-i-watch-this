import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  submit() {
    Turbo.navigator.submitForm(this.element);
  }
}
