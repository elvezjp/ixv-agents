export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        // 背景色
        "bg-base": "rgb(var(--color-bg-base) / <alpha-value>)",
        "bg-surface": "rgb(var(--color-bg-surface) / <alpha-value>)",
        "bg-muted": "rgb(var(--color-bg-muted) / <alpha-value>)",
        "bg-hover": "rgb(var(--color-bg-hover) / <alpha-value>)",
        // テキスト色
        "text-base": "rgb(var(--color-text-base) / <alpha-value>)",
        "text-secondary": "rgb(var(--color-text-secondary) / <alpha-value>)",
        "text-muted": "rgb(var(--color-text-muted) / <alpha-value>)",
        // ボーダー色
        "border-default": "rgb(var(--color-border) / <alpha-value>)",
        "border-muted": "rgb(var(--color-border-muted) / <alpha-value>)",
        // アクセント色
        "accent": "rgb(var(--color-accent) / <alpha-value>)",
        "accent-muted": "rgb(var(--color-accent-muted) / <alpha-value>)",
      }
    }
  },
  plugins: []
};
