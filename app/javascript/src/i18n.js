import { I18n } from 'i18n-js'
import translations from 'src/locales/translations.json'

const i18n = new I18n(translations)

i18n.defaultLocale = document.documentElement.dataset.defaultLocale
i18n.locale = document.documentElement.getAttribute('lang')

export default i18n
