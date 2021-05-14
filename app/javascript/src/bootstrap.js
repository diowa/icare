/* Copied from the source code of Bootstrap: */
/* https://github.com/twbs/bootstrap/blob/v5.0.0/js/index.umd.js */

import Alert from 'bootstrap/js/src/alert'
import Button from 'bootstrap/js/src/button'
// import Carousel from 'bootstrap/js/src/carousel'
import Collapse from 'bootstrap/js/src/collapse'
import Dropdown from 'bootstrap/js/src/dropdown'
import Modal from 'bootstrap/js/src/modal'
// import Offcanvas from 'bootstrap/js/src/offcanvas'
import Popover from 'bootstrap/js/src/popover'
// import ScrollSpy from 'bootstrap/js/src/scrollspy'
// import Tab from 'bootstrap/js/src/tab'
// import Toast from 'bootstrap/js/src/toast'
import Tooltip from 'bootstrap/js/src/tooltip'

export default {
  Alert,
  Button,
  Collapse,
  Dropdown,
  Modal,
  Popover,
  Tooltip
}

$(document).on(window.initializeOnEvent, () => $('[data-bs-toggle="tooltip"]').tooltip())
