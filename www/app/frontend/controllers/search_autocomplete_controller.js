import { Autocomplete } from 'stimulus-autocomplete'

export default class extends Autocomplete {
  static targets = ['submit'];

  connect() {
    super.connect();

    this.element.addEventListener('autocomplete.change', (event) => {
      this.submitTarget.click();
    });
  }

  reopen() {
    if (this.inputTarget.value) {
      this.fetchResults(this.inputTarget.value);
    }
  }
}
