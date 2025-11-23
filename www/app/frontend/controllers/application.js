import { Application } from "@hotwired/stimulus";
import { registerControllers } from "stimulus-vite-helpers";
import { Autocomplete } from "stimulus-autocomplete";

const application = Application.start();
const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
registerControllers(application, controllers);

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
