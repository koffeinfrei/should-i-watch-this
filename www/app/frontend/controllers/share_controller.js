import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String
  }

  connect() {
    if (this.canBrowserShareData({ title: '', text: '', url: '' })) {
      this.element.classList.remove('d-none');
      this.element.classList.add('d-inline');
    }
  }
  async share() {
    await navigator.share({
      title: this.titleValue,
      text: this.textValue,
      url: this.urlValue
    });
  }

  canBrowserShareData(data) {
    if (!navigator.share || !navigator.canShare) {
      return false;
    }

    return navigator.canShare(data);
  }
}
