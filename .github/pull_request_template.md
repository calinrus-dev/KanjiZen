## Description

A summary of the changes introduced by this Pull Request and the problems they solve.

Fixes # (issue number)

## Type of Change

Please mark the options that apply:

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] 💡 New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] ⚡ Performance optimization
- [ ] ♻️ Refactoring / Code Quality (no functional changes)
- [ ] ⚙️ CI/CD / Infrastructure update

## How Has This Been Tested?

Please describe the tests that you ran to verify your changes. Provide instructions so we can reproduce.

1. **Static Analysis:** Run `dart analyze .` to ensure no warnings or lints.
2. **Unit & Widget Tests:** Run `melos run test` to verify unit and widget regressions.
3. **Manual Verification:** Describe the manual steps taken to verify visual/interactive changes (e.g. tested gesture conflict on emulator/device).

## Checklist

Before submitting this PR, please check all that apply:

- [ ] My code follows the style guidelines and architectural standards of this project (e.g. separation of atoms/molecules/organisms in `kz_ui_components`, SRS rules in `kz_domain`).
- [ ] I have performed a self-review of my own code.
- [ ] I have commented my code, particularly in hard-to-understand areas.
- [ ] I have updated any relevant documentation (e.g. `README.md`, `AI_CONTEXT.md`).
- [ ] My changes generate **no new compiler diagnostics or static analysis warnings**.
- [ ] I have added tests that prove my fix is effective or that my feature works.
- [ ] New and existing tests pass locally (ran `melos run test`).
- [ ] Git commit messages follow a clear convention (e.g. Conventional Commits).
