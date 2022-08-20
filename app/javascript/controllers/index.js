// Import and register all your controllers from the importmap under controllers

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers folder
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy loading is required only with a lot of controller
