# Domain 12 — Logging, detection and response

Prevention eventually fails. What decides the size of a breach is how fast someone notices and how prepared they are when they do. The median attacker is inside for weeks before anyone looks.

---

### SEC-131 · Log the security-relevant events
`ASVS:V16` `CWE-778` `T10:A09` · verify: test · severity: high

Login success and failure, MFA changes, password and email changes, permission and role changes, access denied, rate-limit hits, admin and impersonation actions, data exports, API key creation. Each entry records who, what, which object, when, from where, and a correlation ID. Tests assert that these events are emitted, so a refactor cannot silently remove them.

### SEC-132 · Keep secrets and unnecessary personal data out of logs
`ASVS:V16` `CWE-532` `LGPD:art.46` · verify: sast, test · severity: high

Structured logging with a redaction layer for passwords, tokens, cookies, `Authorization` headers, card and document numbers; personal data only where the classification (SEC-073) allows. Logs are copied to more systems, kept longer and read by more people than the database.

### SEC-133 · Ship logs to append-only storage outside the application's reach
`ASVS:V16` `CWE-779` `CIS:8` · verify: config · severity: medium

Centralized, with retention that meets legal and investigative needs, and with credentials the application cannot use to delete or rewrite entries — the first thing an intruder cleans up is the evidence.

### SEC-134 · Alert on signals and route alerts to a person
`ASVS:V16` `T10:A09` · verify: config · severity: high

Spikes in 401/403/429 and 5xx, authentication failures across many accounts, new admins, mass exports, WAF blocks, unusual egress, cost anomalies, and CSP violation reports. An alert nobody receives is a log line. Equifax's attackers were inside for 76 days.

### SEC-135 · Keep an incident response runbook and rehearse it
`CIS:17` `NIST:CSF-2.0` · verify: config · severity: high

Who decides, who to call (hosting, payment provider, lawyer, ANPD contact), and the first-hour steps: contain (kill switch, block, isolate), rotate secrets, revoke sessions and tokens, preserve evidence, communicate. Exercised at least once a year as a tabletop.

### SEC-136 · Notify the ANPD and affected people within the legal deadline
`LGPD:art.48` · verify: config · severity: high

A security incident that may cause relevant risk or damage to data subjects is reported to the ANPD and to the affected people within three business days of becoming aware of it (Resolução CD/ANPD nº 15/2024), with records of the incident kept for five years. The runbook (SEC-135) contains the template and the decision criteria.

### SEC-137 · Publish how to report a vulnerability
`RFC9116` · verify: headers · severity: low

`/.well-known/security.txt` with a contact and a disclosure policy, and a triage deadline for incoming reports. Researchers who cannot find a contact publish instead.

### SEC-138 · Test independently on a schedule
`ASVS:V15` `NIST:SSDF` · verify: config · severity: medium

An external penetration test before launch, after major changes, and at least yearly, scoped by the inventory (SEC-114) and by ASVS level 2; a bug bounty once the basics are solid. The gauntlet finds what is mechanically findable; people find what nobody specified.

### SEC-139 · Feed every security escape back into the gauntlet
`crivo` · verify: config · severity: medium

Each vulnerability found after the gauntlet passed — by a pentest, a researcher, an incident, or production monitoring — is a row in `scoring/calibration/escapes.csv` with category `security` and the `SEC-nnn` it violated, and becomes a planted defect (`scoring/calibration/planted/`) that the gauntlet must catch from then on.
