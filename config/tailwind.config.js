const defaultTheme = require("tailwindcss/defaultTheme")

module.exports = {
  content: [
    "./app/assets/stylesheets/application.tailwind.css",
    "./app/components/**/*",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.html.erb"
  ],
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography")
  ],
  safelist: [],
  theme: {
    extend: {
      colors: {
        aoc: {
          atmospheric: {
            DEFAULT: "#79A2D8",
            light: "#CCDBED"
          },
          bronze: "#FFCC99",
          gold: {
            DEFAULT: "#FFFF66",
            light: "#FFFFCC"
          },
          gray: {
            DEFAULT: "#CCCCCC",
            dark: "#666666",
            darker: "#333340",
            darkest: "#10101A"
          },
          green: {
            DEFAULT: "#009900",
            light: "#99FF99"
          },
          red: "#FFAAAA",
          silver: "#9999CC"
        },
        dark: "#0F0F23",
        other: {
          green: "#00CC00"
        },
        wagon: {
          red: "#FD1015"
        }
      },
      fontFamily: {
        mono: ["\"Source Code Pro\"", ...defaultTheme.fontFamily.mono]
      }
    }
  },
  variants: {}
}
