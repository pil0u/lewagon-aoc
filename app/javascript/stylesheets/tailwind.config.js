const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  mode: 'jit',
  purge: {
    enabled: true,
    content: [
      './app/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js'
    ],
    safelist: [
      'underline',
      'text-aoc-atmospheric',
      'text-aoc-green',
      'text-wagon-red-light',
      'text-xl'
    ]
  },
  theme: {
    extend: {
      colors: {
        aoc: {
          atmospheric: {
            DEFAULT: '#79A2D8',
            light: '#CCDBED'
          },
          gray: {
            DEFAULT: '#CCCCCC',
            dark: '#666666',
            darker: '#333340',
            darkest: '#10101A',
          },
          green: {
            DEFAULT: '#009900',
            light: '#99FF99',
            flash: '#00CC00'
          },
          gold: {
            DEFAULT: '#FFFF66',
            light: '#FFFFCC'
          },
          silver: '#9999CC'
        },
        dark: '#0F0F23',
        wagon: {
          red: {
            DEFAULT: '#FD1015',
            light: '#FE9092'
          }
        }
      },
      fontFamily: {
        mono: ['\"Source Code Pro\"', ...defaultTheme.fontFamily.mono]
      },
    },
  },
  variants: {},
  plugins: [],
}
