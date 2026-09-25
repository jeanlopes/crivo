# .NET — tool matrix (adapter not yet filled)

| Layer | Tool |
|---|---|
| types | `<Nullable>enable</Nullable>`, `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` |
| lint | Roslyn analyzers, `dotnet format --verify-no-changes`; suppressions check on `#pragma warning disable` |
| unit | xUnit/NUnit, randomized order, repeated |
| coverage | `coverlet` + changed-line filter |
| structure | NDepend (CQLinq rules), `NetArchTest` |
| mutation | Stryker.NET |
| property | FsCheck / CsCheck |
| traced | `EventPipe` / `DiagnosticSource` tracer; `netcoredbg` for investigation (not `vsdbg` — its license restricts use outside Microsoft tooling) |
| e2e | Reqnroll (SpecFlow successor) |
| security | `dotnet list package --vulnerable --include-transitive`, `semgrep` + `security/semgrep`, `gitleaks`, `osv-scanner`, `syft`, `trivy config`, `zizmor`, `security/checks/headers.sh`, ZAP baseline, `schemathesis` (P11) |
