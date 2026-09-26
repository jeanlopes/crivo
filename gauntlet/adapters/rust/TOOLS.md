# Rust — tool matrix (adapter not yet filled)

| Layer | Tool |
|---|---|
| types | `cargo check` — the type system is the gate |
| lint | `cargo clippy -- -D warnings -W clippy::cognitive_complexity`; suppressions check on `#[allow]` |
| unit | `cargo nextest run --retries 0`, repeated; nextest randomizes order |
| coverage | `cargo llvm-cov --json` + changed-line filter |
| structure | `cargo-modules`, custom check over `cargo metadata` dependency graph |
| mutation | `cargo-mutants --in-diff` |
| property | `proptest` |
| traced | `tracing` subscriber emitting frames; `lldb-dap` for investigation |
| e2e | `cucumber-rs` |
| security | `cargo audit`, `cargo deny check` (advisories, bans, sources), `semgrep` + `security/semgrep`, `gitleaks`, `osv-scanner`, `syft`, `trivy config`, `zizmor`, `security/checks/headers.sh`, ZAP baseline, `schemathesis` (P11) |
