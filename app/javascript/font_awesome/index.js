import { dom, library } from "@fortawesome/fontawesome-svg-core"

/*
 * Available icons librairies:
 *  "@fortawesome/free-brands-svg-icons"
 *  "@fortawesome/free-regular-svg-icons"
 *  "@fortawesome/free-solid-svg-icons"
 */

import {
  faGithub
} from "@fortawesome/free-brands-svg-icons"

import {
  faPlus,
  faPowerOff,
  faTimes
} from "@fortawesome/free-solid-svg-icons"

library.add(
  faGithub,
  faPlus,
  faPowerOff,
  faTimes
)

dom.watch()
