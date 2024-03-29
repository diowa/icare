import { config, library, dom } from '@fortawesome/fontawesome-svg-core'

import {
  faArrowDown,
  faArrowUp,
  faBan,
  faBanSmoking,
  faBullhorn,
  faCheck,
  faChevronDown,
  faClock,
  faCog,
  faComment,
  faComments,
  faExchangeAlt,
  faExclamationTriangle,
  faFlag,
  faFrown,
  faGlobe,
  faInfoCircle,
  faLeaf,
  faLock,
  faLongArrowAltDown,
  faMeh,
  faMapMarkerAlt,
  faPaw,
  faPencilAlt,
  faPiggyBank,
  faPlus,
  faRedo,
  faRoute,
  faSearch,
  faSignInAlt,
  faSmoking,
  faSmile,
  faThumbsUp,
  faTimes,
  faUsers,
  faUserSecret,
  faWandMagicSparkles,
  faWrench
} from '@fortawesome/free-solid-svg-icons'

import {
  faGithub
} from '@fortawesome/free-brands-svg-icons'

// Prevents flicker when using Turbolinks
// Ref: https://github.com/FortAwesome/Font-Awesome/issues/11924
config.mutateApproach = 'sync'

library.add(
  faArrowDown,
  faArrowUp,
  faBan,
  faBanSmoking,
  faBullhorn,
  faCheck,
  faChevronDown,
  faClock,
  faCog,
  faComment,
  faComments,
  faExchangeAlt,
  faExclamationTriangle,
  faFlag,
  faFrown,
  faGlobe,
  faInfoCircle,
  faLeaf,
  faLock,
  faLongArrowAltDown,
  faMeh,
  faMapMarkerAlt,
  faPaw,
  faPencilAlt,
  faPiggyBank,
  faPlus,
  faRedo,
  faRoute,
  faSearch,
  faSignInAlt,
  faSmoking,
  faSmile,
  faThumbsUp,
  faTimes,
  faUsers,
  faUserSecret,
  faWandMagicSparkles,
  faWrench,

  faGithub
)

dom.watch()
