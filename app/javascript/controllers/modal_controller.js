// Taken from https://github.com/excid3/tailwindcss-stimulus-components/

import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  static get targets () {
    return ['container']
  }

  connect() {
    // The class we should toggle on the container
    this.toggleClass = this.data.get('class') || 'hidden';

    // The ID of the background to hide/remove
    this.backgroundId = this.data.get('backgroundId') || 'modal-background';

    // The HTML for the background element
    this.backgroundHtml = this.data.get('backgroundHtml') || this._backgroundHTML();

    // Let the user close the modal by clicking on the background
    this.allowBackgroundClose = (this.data.get('allowBackgroundClose') || 'true') === 'true';

    // Prevent the default action of the clicked element (following a link for example) when opening the modal
    this.preventDefaultActionOpening = (this.data.get('preventDefaultActionOpening') || 'true') === 'true';

    // Prevent the default action of the clicked element (following a link for example) when closing the modal
    this.preventDefaultActionClosing = (this.data.get('preventDefaultActionClosing') || 'true') === 'true';
  }

  disconnect() {
    this.close();
  }

  open(e) {
    if (this.preventDefaultActionOpening) {
      e.preventDefault();
    }

    if (e.target.blur) {
      e.target.blur();
    }

    // Lock the scroll and save current scroll position
    this.lockScroll();

    // Unhide the modal
    this.containerTarget.classList.remove(this.toggleClass);

    // Insert the background
    if (!this.data.get("disable-backdrop")) {
      document.body.insertAdjacentHTML('beforeend', this.backgroundHtml);
      this.background = document.querySelector(`#${this.backgroundId}`);
    }
  }

  close(e) {
    if (e && this.preventDefaultActionClosing) {
      e.preventDefault();
    }

    // Unlock the scroll and restore previous scroll position
    this.unlockScroll();

    // Hide the modal
    this.containerTarget.classList.add(this.toggleClass);

    // Remove the background
    if (this.background) { this.background.remove() }
  }

  closeBackground(e) {
    if (this.allowBackgroundClose && e.target === this.containerTarget) {
      this.close(e);
    }
  }

  closeWithKeyboard(e) {
    if (e.keyCode === 27 && !this.containerTarget.classList.contains(this.toggleClass)) {
      this.close(e);
    }
  }

  _backgroundHTML() {
    return `<div id="${this.backgroundId}" class="fixed top-0 left-0 w-full h-full" style="background-color: rgba(0, 0, 0, 0.8); z-index: 1;"></div>`;
  }

  lockScroll() {
    // Add right padding to the body so the page doesn't shift
    // when we disable scrolling
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
    document.body.style.paddingRight = `${scrollbarWidth}px`;

    // Save the scroll position
    this.saveScrollPosition();

    // Add classes to body to fix its position
    document.body.classList.add('fixed', 'inset-x-0', 'overflow-hidden');

    // Add negative top position in order for body to stay in place
    document.body.style.top = `-${this.scrollPosition}px`;
  }

  unlockScroll() {
    // Remove tweaks for scrollbar
    document.body.style.paddingRight = null;

    // Remove classes from body to unfix position
    document.body.classList.remove('fixed', 'inset-x-0', 'overflow-hidden');

    // Restore the scroll position of the body before it got locked
    this.restoreScrollPosition();

    // Remove the negative top inline style from body
    document.body.style.top = null;
  }

  saveScrollPosition() {
    this.scrollPosition = window.pageYOffset || document.body.scrollTop;
  }

  restoreScrollPosition() {
    document.documentElement.scrollTop = this.scrollPosition;
  }
}