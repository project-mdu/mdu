/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      keyframes: {
        'tooltip-top': {
          '0%': { opacity: 0, transform: 'translateY(4px)' },
          '100%': { opacity: 1, transform: 'translateY(0)' }
        },
        'tooltip-bottom': {
          '0%': { opacity: 0, transform: 'translateY(-4px)' },
          '100%': { opacity: 1, transform: 'translateY(0)' }
        },
        'tooltip-left': {
          '0%': { opacity: 0, transform: 'translateX(4px)' },
          '100%': { opacity: 1, transform: 'translateX(0)' }
        },
        'tooltip-right': {
          '0%': { opacity: 0, transform: 'translateX(-4px)' },
          '100%': { opacity: 1, transform: 'translateX(0)' }
        }
      },
      animation: {
        'tooltip-top': 'tooltip-top 0.2s ease-out',
        'tooltip-bottom': 'tooltip-bottom 0.2s ease-out',
        'tooltip-left': 'tooltip-left 0.2s ease-out',
        'tooltip-right': 'tooltip-right 0.2s ease-out'
      }
    }
  },
  plugins: [],
}