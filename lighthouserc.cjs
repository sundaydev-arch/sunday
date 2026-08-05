/** @type {import('@lhci/cli').Config} */
module.exports = {
  ci: {
    collect: {
      numberOfRuns: 1,
      url: [
        "http://127.0.0.1:3000/en",
        "http://127.0.0.1:3000/en/about",
        "http://127.0.0.1:3000/en/projects",
        "http://127.0.0.1:3000/en/contact",
      ],
      startServerCommand: "pnpm --filter @sunday/web exec next start --port 3000",
      startServerReadyPattern: "Ready",
      startServerReadyTimeout: 120000,
    },
    assert: {
      assertions: {
        "categories:performance": ["warn", { minScore: 0.7 }],
        "categories:accessibility": ["error", { minScore: 0.9 }],
        "categories:best-practices": ["warn", { minScore: 0.85 }],
        "categories:seo": ["error", { minScore: 0.9 }],
      },
    },
    upload: {
      target: "filesystem",
      outputDir: ".lighthouseci",
    },
  },
};
