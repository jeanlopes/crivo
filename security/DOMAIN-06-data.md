# Domain 6 — Data protection, cryptography and privacy

What is lost in a breach is data. This domain is about having less of it, knowing where it is, making it useless when stolen, and meeting the obligations the LGPD (Lei 13.709/2018) places on anyone who processes personal data of people in Brazil.

---

### SEC-068 · Encrypt every connection, internal ones included
`ASVS:V12` `CWE-319` `T10:A04` · verify: headers, config · severity: high

TLS 1.2 or newer (1.3 preferred) between browser and edge, edge and origin, application and database, application and every third party. Certificates renew automatically and their expiry is monitored: at Equifax (2017) an expired certificate on a traffic-inspection device blinded monitoring for 76 days while data left the network.

### SEC-069 · Use vetted cryptography through high-level APIs
`ASVS:V11` `CWE-327` `CWE-328` `T10:A04` · verify: sast · severity: high

libsodium, Tink, the platform's KMS, or the language's standard high-level primitives. No home-made schemes, no ECB mode, no static or reused IVs/nonces, no MD5 or SHA-1 for anything security-relevant, no comparison of MACs with `==` (use constant-time comparison).

### SEC-070 · Use a cryptographic random generator for every security value
`ASVS:V11` `CWE-338` · verify: sast · severity: high

Session IDs, reset and invitation tokens, OTPs, API keys, salts, nonces, file names that act as capabilities. `Math.random()` and Python's `random` are predictable. Use `crypto.randomBytes`/`crypto.randomUUID`, `secrets`, or the OS generator.

### SEC-071 · Keep secrets in a secret manager, never in code, images or chat
`ASVS:V13` `CWE-798` `T10:A04` · verify: secrets, iac · severity: critical

Injected at runtime, scoped per environment, rotated on a schedule and immediately on suspicion, each with a named owner. Never in the repository (history included), Docker layers, `.env` files that get committed, CI logs, tickets, or an agent's context window. Uber (2016) lost 57 million records through cloud keys committed to a private GitHub repository. A leaked secret is revoked first and investigated second — deleting the commit does not un-leak it.

### SEC-072 · Encrypt data at rest, and encrypt the most sensitive fields in the application
`ASVS:V11` `ASVS:V14` `CWE-311` · verify: config, iac · severity: high

Disk, database, object storage and backups encrypted with managed keys. Fields whose exposure would be catastrophic — identity documents, health data, third-party tokens (SEC-054), bank details — additionally encrypted by the application with keys the database administrator cannot read.

### SEC-073 · Classify every piece of data the system stores
`ASVS:V14` `LGPD:art.6` · verify: adversary · severity: medium

Each field is public, internal, personal or sensitive personal data (LGPD art. 5 II: health, biometrics, religion, political opinion and others), with a purpose, a legal basis (art. 7, art. 11) and a retention period. Classification lives in the schema or the SPEC threat model, so the adversary and the logging rules (SEC-132) can use it.

### SEC-074 · Collect, return and keep the minimum
`ASVS:V14` `CWE-359` `CWE-213` `LGPD:art.6` · verify: test, adversary · severity: high

Data not collected cannot leak. APIs return what the screen needs, not the whole record (excessive data exposure); list endpoints return summaries; data past its retention is deleted by a scheduled job, not by intention.

### SEC-075 · Honour data subject rights end to end
`LGPD:art.18` · verify: test · severity: medium

Access, correction, portability and deletion requests reach every copy: primary store, search indexes, caches, analytics, logs where feasible, and processors. Deletion that leaves the data in a search index is not deletion.

### SEC-076 · Keep backups that an attacker in production cannot destroy, and prove they restore
`ASVS:V14` `CIS:11` · verify: config · severity: high

Encrypted, in a separate account or with immutability (object lock), with credentials production does not hold. A restore is exercised on a schedule and timed; the result is the recovery time you actually have. Ransomware operators delete backups first.

### SEC-077 · Show clients generic errors; keep details in logs
`ASVS:V16` `CWE-209` `T10:A10` · verify: dast, test · severity: medium

No stack traces, SQL fragments, file paths, framework versions or internal hostnames in responses. Return a correlation ID the user can quote to support.

### SEC-078 · Fail closed when a security check errors
`ASVS:V16` `CWE-636` `CWE-755` `T10:A10` · verify: test, adversary · severity: critical

An exception inside authorization, validation, signature verification, payment confirmation or rate limiting must deny, never allow. `catch (e) { return true }` in a policy check is a vulnerability, and so is a rate limiter that lets everything through when its cache is down unless that degradation is a recorded decision (ADR, P10).

### SEC-079 · Keep production personal data out of non-production environments
`ASVS:V14` `CWE-200` `LGPD:art.46` · verify: adversary · severity: high

Development, test, staging, preview deployments and AI agents work with synthetic or irreversibly masked data. A staging database copied from production is a production database with weaker controls.
