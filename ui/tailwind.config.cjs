/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend:
    {
      fontFamily: {
        'sans': ['Catamaran', 'sans-serif'],
        'roboto': ["Roboto Slab", 'serif']
      },
    },
  },
  plugins: [],
}
