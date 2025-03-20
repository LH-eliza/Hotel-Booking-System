module.exports = {
    semi: true,
    trailingComma: 'all',
    singleQuote: true,
    printWidth: 100,
    tabWidth: 2,
    useTabs: false,
    bracketSpacing: true,
    jsxBracketSameLine: false,
    arrowParens: 'avoid',
    endOfLine: 'lf',
    overrides: [
      {
        files: '*.{ts,tsx}',
        options: {
          parser: 'typescript',
        },
      },
    ],
  };