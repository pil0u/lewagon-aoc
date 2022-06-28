// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

// --------------------------------------------------------------------------------------------------------------------

// // Load all the controllers within this directory and all subdirectories. 
// // Controller files must be named *_controller.js.

// import { Application } from "@hotwired/stimulus"
// import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
// import ScrollTo from 'stimulus-scroll-to'

// const application = Application.start()
// application.register("scroll-to", ScrollTo)

// const context = require.context("controllers", true, /_controller\.js$/)
// application.load(definitionsFromContext(context))
