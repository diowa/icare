import neostandard, { resolveIgnoresFromGitignore } from 'neostandard'

export default [
  {
    name: 'Custom Ignores',
    ignores: [
      ...resolveIgnoresFromGitignore(),
      'app/assets/config/manifest.js',
      'app/assets/javascript/**/vendor/*.js',
      'config/**/*.js',
    ],
  },
  ...neostandard(),
  {
    name: 'Custom Rules',
    rules: {
      'object-shorthand': 'off',
      '@stylistic/comma-dangle': ['error', {
        arrays: 'always-multiline',
        objects: 'always-multiline',
        imports: 'never',
        exports: 'never',
        functions: 'never',
      }],
    },
  },
  {
    name: 'Custom Globals',
    languageOptions: {
      globals: {
        $: true,
        ClientSideValidations: true,
        google: true,
        Handlebars: true,
        HandlebarsTemplates: true,
        I18n: true,
        InfoBox: true,
        initGoogleMaps: true,
      },
    },
  },
]
