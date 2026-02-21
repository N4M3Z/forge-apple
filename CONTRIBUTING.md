# Contributing

## Module structure

forge-apple follows the [Module Standard](../../ARCHITECTURE.md#module-standard). The source of truth for skills is `skills/` in this module — the `.opencode/skills/` copies are deployed by forge-core and should not be edited directly.

## Code style

- Shell scripts start with `set -euo pipefail`
- Quote all variables: `"$VAR"`, not `$VAR`
- Use `command rm`, `command cp`, `command mv` — never bare (macOS aliases add `-i`)
- AppleScript blocks use heredoc with `<<'APPLESCRIPT'` (single-quoted delimiter prevents shell interpolation)
- Pass [shellcheck](https://www.shellcheck.net/) with no warnings

## Configuration

- `defaults.yaml` — shipped defaults, tracked in git. Keep values generic.
- `config.yaml` — user overrides, gitignored. Personal or locale-specific values go here.

When adding new configurable values, add a generic default to `defaults.yaml` with a comment explaining the override pattern.

## Skills

Each skill follows the index + operation pattern:

```
skills/SkillName/
├── SKILL.md              # Index: name, description, operations table, tools, limitations
├── OperationOne.md       # Steps for a specific operation
└── OperationTwo.md       # Steps for another operation
```

- `SKILL.md` frontmatter must include `name`, `description` (with `USE WHEN` triggers), and `user_invocable: true`
- Operation files describe steps, not implementation — the scripts in `bin/` do the work

## Dependencies

This module relies on macOS-only tools:

- **AppleScript** — Safari, Music.app automation
- **SQLite** — CloudTabs.db access
- **ekctl** — Calendar + Reminders (external, optional)

New features should degrade gracefully when optional dependencies are missing.

## Pull requests

1. Create a feature branch
2. Make changes
3. Test on macOS — there is no CI (AppleScript requires a GUI session)
4. Run `shellcheck bin/*.sh` — clean
5. Open a PR with a clear description
