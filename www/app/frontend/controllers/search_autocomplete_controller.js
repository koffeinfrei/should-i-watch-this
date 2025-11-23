import { Autocomplete } from "stimulus-autocomplete";

export default class extends Autocomplete {
  connect() {
    super.connect();

    this.element.addEventListener("autocomplete.change", (event) => {
      this.inputTarget.value = "";
      Turbo.visit(event.detail.value);
    });
  }

  reopen() {
    if (this.inputTarget.value) {
      this.fetchResults(this.inputTarget.value);
    }
  }

  showAll(event) {
    Turbo.visit(event.params.url);
  }
}
