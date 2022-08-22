module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  extends: "eslint:all",
  ignorePatterns: [
    "**/app/assets/config/manifest.js",
    "**/app/javascript/controllers/countdown_controller.js",
    "**/app/javascript/controllers/modal_controller.js"
  ],
  parserOptions: {
    sourceType: "module"
  },
  reportUnusedDisableDirectives: true,
  rules: {
    "array-element-newline": ["error", "consistent"],
    "function-call-argument-newline": ["error", "consistent"],
    "indent": ["error", 2],
    "lines-around-comment": ["error", { allowBlockStart: true }],
    "no-magic-numbers": "off",
    "object-curly-spacing": ["error", "always"],
    "padded-blocks": ["error", { blocks: "never" }],
    "quote-props": ["error", "consistent-as-needed"],
    "semi": ["error", "never"]
  }
}
