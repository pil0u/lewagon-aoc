import { dom, library } from "@fortawesome/fontawesome-svg-core"

/*
 * Available icons librairies:
 *  "@fortawesome/free-brands-svg-icons"
 *  "@fortawesome/free-regular-svg-icons"
 *  "@fortawesome/free-solid-svg-icons"
 */

import {
  faPowerOff,
  faTimes
} from "@fortawesome/free-solid-svg-icons"

library.add(
  faPowerOff,
  faTimes
)

dom.watch()
