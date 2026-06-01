## Testing Capabilities

**Strict TDD Mode**: disabled
**Detected**: 2026-05-31

### Test Runner

- Command: — (none detected)
- Framework: — (none installed)

### Test Layers

| Layer       | Available | Tool        |
| ----------- | --------- | ----------- |
| Unit        | ❌        | —           |
| Integration | ❌        | —           |
| E2E         | ❌        | —           |

### Coverage

- Available: ❌
- Command: —

### Quality Tools

| Tool         | Available | Command            |
| ------------ | --------- | ------------------ |
| Linter       | ❌        | —                  |
| Type checker | ✅        | `npm run typecheck`|
| Formatter    | ❌        | —                  |

### Notes

- No test framework (Jest, Vitest, React Native Testing Library) is installed.
- No linting (ESLint) or formatting (Prettier) configured.
- TypeScript strict mode is enabled via `tsconfig.json`.
- To enable testing: `npm install --save-dev jest @testing-library/react-native @testing-library/jest-native react-native-testing-library` plus Jest preset for React Native.
