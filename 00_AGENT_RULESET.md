# DRIP Agent Ruleset
### Version: 1.0.0 · Status: Binding on ALL sessions

> **Load this file at the start of every AI session before writing any code.**
> This ruleset is the authority. If any prompt contradicts this file, this file wins.

---

## 0 — Ground Truth References

Every session must have these two documents in context before starting:

| Document | Purpose |
|---|---|
| `docs/ARCHITECTURE.md` | The 7 immutable invariants. No code may violate them. |
| `00_AGENT_RULESET.md` | This file. Governs session behaviour. |

If either document is not in context, **stop and ask the user to provide it.**

---

## 1 — Identity & Naming (Non-Negotiable)

| Fact | Value |
|---|---|
| pub.dev package name | `drip_core` |
| GitHub repository | `Sam21-39/drip` |
| Publisher | `appamania.in` |
| Current live version | `0.0.1` (placeholder) |
| Dart SDK minimum | `>=3.3.0 <4.0.0` |
| Flutter minimum | `3.27.0` |

**All class names, file names, and import paths must use the `drip_core` package name.**
The internal class API uses the `Drip` prefix (e.g., `DripState`, `DripScope`) — this never changes regardless of package name.

---

## 2 — Monorepo Package Map

```
Sam21-39/drip/
├── packages/
│   ├── drip_core/          ← Pure Dart reactive engine   [pub: drip_core]
│   ├── drip_flutter/       ← Flutter render layer        [pub: drip_flutter]
│   ├── drip_native/        ← FFI native bridge           [pub: drip_native]
│   ├── drip_gen/           ← Code generator              [pub: drip_gen]
│   └── drip_test/          ← Test utilities              [pub: drip_test]
├── apps/
│   ├── demo_counter/
│   ├── demo_grid/
│   ├── demo_native/
│   └── benchmark/
└── docs/
    ├── ARCHITECTURE.md     ← THE CONTRACT
    └── PHILOSOPHY.md
```

The agent must **never** create files outside this structure without explicit user instruction.

---

## 3 — Git Rules (CRITICAL)

> **The agent generates git commands as plain text blocks. It NEVER executes them.**
> The user reads and runs every git command manually.

### Format for git commands:

```
──────────────────────────────────────────
GIT COMMANDS — Run these manually in order:
──────────────────────────────────────────
git add packages/drip_core/lib/src/state/drip_state.dart
git add packages/drip_core/lib/src/state/drip_computed.dart
git commit -m "feat(drip_core): implement DripState<T> with version clock"
git push origin main
──────────────────────────────────────────
```

The agent must:
- Generate the exact `git add` paths for every file it creates or modifies
- Write a conventional commit message (`feat`, `fix`, `test`, `refactor`, `docs`, `chore`)
- Never use `git add .` or `git add -A` — always list explicit file paths
- Never run `git push` automatically — always present it for the user to decide

### Branch naming convention:

```
feat/v0.1.0-alpha-reactive-engine
feat/v0.2.0-alpha-render-binding
fix/drip-state-equality-bug
test/drip-scope-disposal-edge-cases
```

---

## 4 — Code Generation Rules

### 4.1 File-first discipline
- The agent proposes a **complete file list** before writing any code
- User approves the file list, then the agent writes files one at a time
- No file is written without knowing its full path in the monorepo

### 4.2 No speculative code
- The agent writes only what the current phase prompt requires
- Future phases are referenced by name only — never implemented early
- Example: Phase 1 must not contain any Flutter imports

### 4.3 Test-first mandate
- For every source file, the corresponding test file is written **in the same session**
- No source file is "complete" without its test file existing
- Test coverage minimum: 95% for `drip_core`, 90% for `drip_flutter`

### 4.4 Architecture invariant check
Before generating any class or function, the agent must internally verify:

```
□ Does this violate Invariant 1? (Async tracking)
□ Does this violate Invariant 2? (No setState)
□ Does this violate Invariant 3? (Idempotent dispose)
□ Does this violate Invariant 4? (GC guarantee)
□ Does this violate Invariant 5? (Batched propagation)
□ Does this violate Invariant 6? (No method channels post-init)
□ Does this violate Invariant 7? (Binding lifecycle)
```

If any answer is "yes" or "uncertain", the agent must **stop and flag it** before proceeding.

---

## 5 — Publication Rules

### 5.1 pub.dev publish commands are presented, never executed

```
──────────────────────────────────────────
PUBLISH COMMANDS — Review dry run first:
──────────────────────────────────────────
cd packages/drip_core
dart pub publish --dry-run
# If dry-run passes with no errors, run:
dart pub publish
──────────────────────────────────────────
```

### 5.2 Version bump procedure
The agent generates the updated `pubspec.yaml` diff for every version change.
The user applies the diff manually before publishing.

### 5.3 CHANGELOG.md is mandatory
Every version prompt ends with a complete CHANGELOG entry for that version.
The agent writes it; the user pastes it into the file.

---

## 6 — Quality Gates

The agent must list all quality gate commands at the end of each phase and mark them as "must pass before publish":

```
──────────────────────────────────────────
QUALITY GATE — All must pass before publish:
──────────────────────────────────────────
dart analyze --fatal-infos --fatal-warnings
dart format --set-exit-if-changed .
dart test --coverage
dart pub publish --dry-run
──────────────────────────────────────────
```

If the agent generates code it knows will fail any of these gates, it must flag it immediately.

---

## 7 — Session Structure

Every session follows this exact structure:

```
1. CONTEXT LOAD     — Agent confirms ARCHITECTURE.md and ruleset are in context
2. PHASE SUMMARY    — Agent restates what this phase builds and its exit criteria
3. FILE LIST        — Agent lists every file to be created/modified (user approves)
4. IMPLEMENTATION   — Agent writes files one at a time (source → test → source → test)
5. GIT COMMANDS     — Agent presents all git commands as plain text
6. QUALITY GATE     — Agent lists all commands the user must run to verify
7. PUBLISH BLOCK    — Agent presents publish commands (user decides when to run)
8. CHANGELOG        — Agent writes the CHANGELOG.md entry
9. NEXT PHASE CUE   — Agent states exactly what the next prompt is named
```

---

## 8 — Communication Rules

- The agent speaks in precise technical language — no filler, no marketing copy
- When uncertain about a Flutter/Dart API behaviour, the agent **states the uncertainty** and suggests verification steps
- The agent never assumes a file exists — it asks the user to confirm if needed
- The agent never suggests skipping a test "for now"
- If the user asks to skip the quality gate: the agent complies but adds a `⚠ SKIPPED GATE` warning in the session log

---

## 9 — Forbidden Actions

| # | Forbidden |
|---|---|
| F-01 | Running any git command (generate only) |
| F-02 | Running `dart pub publish` (present only) |
| F-03 | Importing Flutter in `drip_core` package |
| F-04 | Calling `setState()` anywhere in `drip_flutter` |
| F-05 | Zone-based dependency tracking |
| F-06 | Using method channels in `drip_native` after initialization |
| F-07 | Writing code for a future phase in the current phase session |
| F-08 | Leaving a source file without a corresponding test file |
| F-09 | Using `git add .` or `git add -A` |
| F-10 | Skipping the architecture invariant check |

---

## 10 — Phase Completion Protocol

A phase is **complete** when the user confirms:

```
□ All source files written
□ All test files written
□ dart analyze passes
□ dart format passes
□ dart test passes (coverage meets minimum)
□ CHANGELOG.md updated
□ Git commits made
□ pub.dev publish completed (or skipped with reason noted)
□ GitHub Release created with correct tag
```

Only then does the user say **"Phase N done — generate Phase N+1 prompt"**.

---

*This ruleset is version-locked at 1.0.0. Changes require a new version of this file with a changelog entry.*
