import { Autocomplete } from 'stimulus-autocomplete'

export default class extends Autocomplete {
  static targets = ['submit'];

  connect() {
    super.connect();
    this.element.addEventListener('autocomplete.change', (event) => {
      this.submitTarget.click();
    });
  }
}
