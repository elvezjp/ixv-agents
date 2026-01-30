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
        "text-strong": "rgb(var(--color-text-strong) / <alpha-value>)",
        "text-default": "rgb(var(--color-text-default) / <alpha-value>)",
        "text-secondary": "rgb(var(--color-text-secondary) / <alpha-value>)",
        "text-muted": "rgb(var(--color-text-muted) / <alpha-value>)",
        // ボーダー色
        "border-default": "rgb(var(--color-border) / <alpha-value>)",
        "border-strong": "rgb(var(--color-border-strong) / <alpha-value>)",
        "border-muted": "rgb(var(--color-border-muted) / <alpha-value>)",
        // プライマリ色 (リンク、主要ボタン)
        "primary": "rgb(var(--color-primary) / <alpha-value>)",
        "primary-hover": "rgb(var(--color-primary-hover) / <alpha-value>)",
        "primary-light": "rgb(var(--color-primary-light) / <alpha-value>)",
        "primary-ring": "rgb(var(--color-primary-ring) / <alpha-value>)",
        // アクセント色 (選択状態等)
        "accent": "rgb(var(--color-accent) / <alpha-value>)",
        "accent-hover": "rgb(var(--color-accent-hover) / <alpha-value>)",
        "accent-light": "rgb(var(--color-accent-light) / <alpha-value>)",
        // ステータス色 - 成功
        "success": "rgb(var(--color-success) / <alpha-value>)",
        "success-hover": "rgb(var(--color-success-hover) / <alpha-value>)",
        "success-light": "rgb(var(--color-success-light) / <alpha-value>)",
        // ステータス色 - 警告
        "warning": "rgb(var(--color-warning) / <alpha-value>)",
        "warning-hover": "rgb(var(--color-warning-hover) / <alpha-value>)",
        "warning-light": "rgb(var(--color-warning-light) / <alpha-value>)",
        // ステータス色 - エラー
        "danger": "rgb(var(--color-danger) / <alpha-value>)",
        "danger-hover": "rgb(var(--color-danger-hover) / <alpha-value>)",
        "danger-light": "rgb(var(--color-danger-light) / <alpha-value>)",
      }
    }
  },
  plugins: []
};
