// Load all the controllers within this directory and all subdirectories. 
// Controller files must be named *_controller.js.

import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"
import ScrollTo from 'stimulus-scroll-to'

const application = Application.start()
application.register("scroll-to", ScrollTo)

const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))
