# PLAN — Gherkin regression and visual parity with a legacy system

A reusable plan for a **rewrite or port** where the old system is still around: write *every* business rule and functional requirement of *every* screen as executable Gherkin, tie each scenario to the automated test that proves it, run the lot as a regression, and prove screen-by-screen parity with the old system using side-by-side screenshots.

> Extracted from a real execution (a ~16-screen industrial MES ported from a .NET Framework monolith to ASP.NET Core + React): 81 features, 1,227 scenarios (3,511 executions, all green), 1,131 rules/requirements cited, and 479 side-by-side screenshot states. The numbers are there to calibrate your estimate; every product-specific name was removed. Replace the `<…>` placeholders.

**One sentence.** Make the spec the map of the system: Gherkin says *what* is true, tags say *which rule* and *which test*, a gate fails the build when the map and the territory drift, and a manifest-driven capturer shows the old and new screens next to each other.

## 0. Deliverables

| Ask | Deliverable | Phase |
|---|---|---|
| Gherkin for ALL rules and requirements of all pages | `spec/features/<NN-section>/*.feature` | 1–2 |
| Navigable sections, links to each automated test | generated `spec/INDEX.md` + one `README.md` per section | 3 |
| A regression built from it | a test project that **executes** the scenarios + a traceability gate | 3–4 |
| Old × new screenshots, per screen and per *unfolding* (modal, state, clicked button…) | `docs/reports/screenshots/<section>/<screen>/<NN-state>.jpg` + `INDEX.md` | 5 |
| Evidence at the end | green regression, index, screenshot folder, gap list | 6 |

## 1. Decisions (and the rejected alternative)

**D1 — One `.feature` per functionality, in `spec/features/<NN-section>/`, in the team's working language** (`# language: <xx>`). Gherkin exists to be read by people who do not code, so use their vocabulary. *Rejected:* English by default when the domain and the stakeholders speak another language.

**D2 — The executor lives in the product's own test runner** (Cucumber for your stack: Reqnroll/SpecFlow, cucumber-js, Behave, Cucumber-JVM…), inside the normal test command. Rule scenarios talk to the real host (in-memory server + the same test database the unit tests use) and need **no external services**, so they run in CI. The browser only enters where the rule lives in the UI (`@ui`). *Rejected:* a browser-driven suite for everything — it needs the whole stack up on every run, and most rules (uniqueness, soft-delete, filters, converted stored procedures) are server rules.

**D3 — Traceability is data, not prose.** Every scenario carries tags:
- `@RN-<AREA>-nn` — business rule; `@RF-<AREA>-nn` — functional requirement (AREA = 2–6 uppercase letters, unique per section);
- `@proof:<Class>.<Method>` / `@proof:web/…/x.test.tsx` — the **existing** automated test that also proves it (existing tests are *referenced*, not rewritten);
- `@ui`, `@no-db`, `@channel`… — the execution axis;
- `@gap` — the legacy did it and the new system **deliberately does not**, with the reason in the lines under the title.

A gate test **fails the build** when: a feature lacks the language header or the `@section:` tag matching its folder; a scenario cites no `@RN`/`@RF` (or in the wrong format); a `@proof:` points to a test that does not exist; a `@gap` has no reason; the generated index is stale. This is the "every scenario maps to at least one automated test" rule made executable. Undefined steps must be **errors**, never "ignored" (`missingOrPendingStepsOutcome: Error` in Reqnroll; the equivalent elsewhere).

**D4 — No redundancy: tables, not copies.** The same behaviour over several entities is a `Scenario Outline` with `Examples`. One reusable step per concept. A rule an existing test already proves in depth is *described and referenced*, not re-implemented; only what Gherkin makes readable and nobody wired end to end gets its own steps.

**D5 — Visual parity is a manifest, not a script.** `spec/parity/<NN-section>.json` lists, per screen, the **states** (how to reach each one in the old and in the new system, or that a side is unavailable and why). One capturer (Playwright) reads the manifests, captures both sides, **composes one image old|new**, and writes the index. A Playwright MCP is fine for *exploring* the old system to discover unfoldings; what stays in the repo is the manifest, repeatable by anyone. *Rejected:* manual screenshots — they cannot be repeated, and "everything is covered" becomes an opinion.

**D6 — The old system must run.** Pin down *how* it is started (web server, DB restored from a backup, credentials) in `spec/parity/README.md` before writing anything else. Phase 0 re-proves it.

## 2. Layout

```
spec/
  README.md            how to read/write, tags, what breaks the build
  INDEX.md             GENERATED: section → feature → scenario → rule → test (links)
  MATRIX.md            screen × requirement: the measure of "everything"
  matrix/<section>.md  one table per section (see Phase 1)
  SECTION-GUIDE.md     instructions for whoever writes a section (also used by parallel agents)
  features/<NN-section>/*.feature  (+ generated README.md per section)
  parity/<NN-section>.json         the capture manifests
docs/reports/screenshots/<section>/<screen>/<NN-state>.jpg   old | new
docs/reports/screenshots/INDEX.md                             the grid, with the gaps
<tests>/Regression.Tests/   steps, bindings to the host, traceability gate, index generator
scripts/parity/capture.mjs  the capturer / composer / indexer
```

## 3. Phases

**Phase 0 — Foundations (small, first).** Conventions README; the regression test project; **one vertical slice** (one simple screen) from `.feature` to green test, generated index and one side-by-side capture. If the slice does not close, change the plan *here*. Acceptance: the scenario runs; the gate **bites** (remove a tag, see red); the index links open.

**Phase 1 — Survey: the screen × requirement matrix.** Sources, in order of authority: the legacy code (controllers/views/stored procedures — read-only), the project's own inventory/ADR documents, the new system's routes and screens, **and the existing tests** (they say what is already proven). Deliverable `spec/matrix/<section>.md`: `Screen | ID | Requirement or rule | Origin | Does the new system do it? (yes / partial / no / gap) | Scenario | Existing proof`. The matrix *is* the definition of "all": the plan ends when it has no empty cell.

**Phase 2 — Write the features, section by section** (most protective first). For each: read the matrix; write the happy path, **every refusal**, every permission (role × action), and every variation axis as `Examples` rows; mark `@gap`; add `@proof`. If a scenario fails because the new system violates the rule, that is a **defect**: write the correct scenario, fix the product *with a test* (or file an issue if it is a product decision) — never hide it in the Gherkin and never leave a scenario red or ignored.

**Phase 3 — Index and gate.** A generator (same pattern as golden files: `UPDATE_SPEC=1 <test command> --filter Index`) writes `INDEX.md` and each section README from the tags; a test compares generated against committed. The traceability gate from D3 runs in the normal test command.

**Phase 4 — The executable regression.** Reusable steps (one file per concept). Execution modes chosen **by tag**, not by project: default (in-memory host + test DB), `@no-db` (host without the DB: the branch every screen must draw), `@channel` (several hosts talking to each other), `@ui` (real host + browser, only for what lives in the UI). Acceptance: the regression is green with zero ignored tests and zero compiler warnings; **each section has at least one scenario verified red** by temporarily breaking the rule or the expectation.

**Phase 5 — Visual parity.**
1. Capturer driven by manifests, with a tiny step vocabulary (`goto`, `click`, `fill`, `select`, `press`, `waitFor`, `hover`, `contextClick`, and the flags `noSession` / `freshContext`). It never saves data: the old system's `confirm/alert` is dismissed and no step clicks Save/Delete for real.
2. Discover unfoldings in the old system: modals, tabs, clicked buttons, applied filters, selected row, empty state, validation error.
3. Capture both sides; compose `old | new` with a caption; store as **JPEG** (hundreds of full-page PNGs add up to tens of MB). Keep raw per-side captures out of git.
4. *Cannot be opened* (server-side reports, print views, environment errors): left side blank **with the reason**; only the new one is shown.
5. *Old screen without a counterpart*: right side blank with "no equivalent — see `@gap`"; it enters the gap list.
6. `INDEX.md` with counts: pairs, new-only, old-only (= gaps), no capture.

**Phase 6 — Close.** Full run (unit + front + e2e + regression + captures), project guide pointing to the spec as source of truth, gap report, PR.

## 4. Variation matrix (every path has a scenario)

| Axis | Values | Where |
|---|---|---|
| Database | with · without | `@no-db` |
| Permission | has · lacks · role/domain · anonymous | role × action `Examples` for every resource |
| Authentication mode | each configured provider · password · both | access section |
| Row state | active · inactive | every list and every uniqueness rule |
| Product-specific axes | e.g. device type × transport × outcome | `Examples` over the simulator/twin |
| Deployment mode | e.g. channel × local server | system/integration section |

## 5. Out of scope

Rewriting the existing tests (they are referenced; replace one only if a scenario makes it redundant, with the reason in the commit); real-equipment validation and installer proofs (not code — track as issues); new features (a rule the new system lacks is a defect or a `@gap`, never silently added); pixel-perfect parity (parity is of **content and behaviour**: fields, columns, buttons, states, messages).

## 6. Risks

| Risk | Answer |
|---|---|
| Gherkin becomes prose nobody runs | D3 gate + Phase 4 (scenarios execute and are verified red) |
| "ALL rules" has no end | the matrix is the measure, and it is generated from the sources |
| The old system will not start / data differs | D6 and Phase 0; write the start-up recipe down |
| Fragile captures (data changes) | seed idempotently; stable clock and names; never show generated ids |
| Repository weight | JPEG ≤ ~2000 px wide, raw captures ignored by git |
| Two sources of truth (spec × tests) | the spec **references** the test and the gate checks it |

## 7. Acceptance

1. `spec/features/**` with all rules and requirements; `MATRIX.md` with no empty cell.
2. `INDEX.md` navigable: section → feature → scenario → test, links open.
3. Regression green (0 failed, 0 ignored, 0 warnings, no suppressions), plus the earlier suites.
4. The screenshot folder with per-section subfolders, the pairs, and the gap list.

## 8. Executing it in parallel (what worked, and what bit)

The sections are independent, so they parallelise: **one agent (or person) per section**, each in an isolated worktree, each owning only its own files (`features/<section>/`, `matrix/<section>.md`, `Steps/<Section>*`, a per-section service registration). Give them `SECTION-GUIDE.md`: deliverables in order, sources and their authority, coexistence rules, the "found a defect" protocol, and a short final report (files, counts, gaps, defects, uncovered legacy rules, what to promote to shared infra, branch + hash). The visual manifests are a separate, parallel stream (one agent per two or three sections) running against *shared* old/new servers — the capturer must never write data.

Lessons that cost time on the first run:

- **Step-text collisions** between sections ("ambiguous step definitions") are inevitable. Prefix steps with the section's own noun and anchor regexes (`^…$`); when two sections still collide, scope the binding by tag (`[Scope(Tag="section:NN-name")]` in Reqnroll) instead of renaming scenarios.
- **Regex vs Cucumber-expression detection.** Many runners treat a string as a Cucumber expression unless it is anchored; `(\d+)` then means "optional text", `a/b` means alternation, and `cores?` matches "core"/"cores" but **not** "cor". Anchor every regex step; test singular and plural.
- **Optional regex groups** that do not participate in the match can produce "parameter count mismatch": use one capturing group around the optional part, or two step definitions.
- **A "Given" will not match after a "When" with "And"** in some runners: give the step both attributes.
- **Shared mutable state** across scenarios — one test database, one fake clock — makes results depend on run order. Reset what each section uses at the start of its scenarios, and make time-dependent expectations relative (`{now}`): a fake clock usually cannot go backwards.
- **Do not commit generated code-behind** (`*.feature.cs` and the like); ignore it and the agents' worktree folder. Also make repo-wide "dead code" scanners skip the spec folder and the worktrees.
- **Whole-database tests are sensitive to the dev server**: running the app against the shared dev database (background jobs!) can consume state that other tests rely on. Capture against a throwaway copy, or note which tests depend on dev data.
- **A test project may reference another test project** for the in-memory host fixtures — keep one bench, never two. A small per-section service-registration interface, discovered by reflection, avoids everyone editing one shared file.
- **Capturing the old system can hurt it**: it may write on login, language change or failed-login logging. List the dangerous clicks per screen and keep them out of the manifest.
- **Agents hit usage limits mid-section.** Keep each section's work committable in small steps; a resumed agent starts from the worktree's uncommitted files.

## 9. Order of work (checklist)

- [ ] Start-up recipe for the old system, written and proven
- [ ] Phase 0 slice green, gate bites, one capture composed
- [ ] `SECTION-GUIDE.md` + step conventions + per-section registration hook
- [ ] Sections fan-out (features + matrix) · visual manifests fan-out
- [ ] Merge; resolve step collisions; regenerate the index
- [ ] Full regression green; screenshots regenerated from a clean state
- [ ] Gap and defect report; PR
