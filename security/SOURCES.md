# Sources — the reference manuals, and which one to open for what

There is no single "world security manual". There is a small set of references that the industry treats as canonical, each with a different job. The catalogue cites them by sigil (README, *Entry format*); this page says what each is for and how they relate, so you open the right one.

## The standards (what to build and verify)

| Reference | Sigil | Use it for |
|---|---|---|
| [OWASP ASVS 5.0](https://github.com/OWASP/ASVS) (Application Security Verification Standard, May 2025) | `ASVS:Vn` | **The backbone.** ~350 verifiable requirements for web apps and APIs in 17 chapters, in three levels. When a control here needs detail, the ASVS chapter has it. Level 2 is the target for a SaaS with personal data. |
| [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) | — | **How to implement** a control: concrete, per-topic guidance (CSP, session management, password storage, SSRF, OAuth, file upload…). The most practical page to hand an agent. |
| [OWASP Top 10 Proactive Controls](https://top10proactive.owasp.org/) | — | A developer-facing summary of the ten things to always do. Onboarding reading. |
| [NIST SP 800-63-4](https://pages.nist.gov/800-63-4/) (Digital Identity Guidelines, 2025) | `NIST:800-63B-4` | Passwords, MFA, authenticators, sessions — the source of the modern password rules (SEC-038). |
| [NIST SP 800-218 SSDF](https://csrc.nist.gov/pubs/sp/800/218/final) | `NIST:SSDF` | The secure development process: what an organisation does, not what the code does. crivo's gauntlet is one implementation of its "produce well-secured software" practices. |
| [NIST Cybersecurity Framework 2.0](https://www.nist.gov/cyberframework) | `NIST:CSF-2.0` | Organisation-wide: govern, identify, protect, detect, respond, recover. |
| [CIS Critical Security Controls v8.1](https://www.cisecurity.org/controls) | `CIS:n` | Prioritised operational controls: inventory, patching, logging, backups, incident response. |
| [SLSA](https://slsa.dev/) and [OpenSSF Scorecard](https://scorecard.dev/) | `SLSA` | Supply-chain integrity levels for builds; automated checks of a repository's supply-chain hygiene. |
| [PCI DSS 4.0](https://www.pcisecuritystandards.org/) | `PCI:n` | Only if you touch card data; requirements 6.4.3 and 11.6.1 (payment-page scripts) are worth following anyway (SEC-029). |
| ISO/IEC 27001:2022, SOC 2 | — | Certifications of an organisation's security management. Customers ask for them; they prove process, not code. |
| [LGPD — Lei 13.709/2018](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm) and [ANPD](https://www.gov.br/anpd/) regulations | `LGPD:art.n` | Legal obligations for personal data of people in Brazil: principles (art. 6), legal bases (art. 7, 11), rights (art. 18), security (art. 46), incident communication (art. 48; Resolução CD/ANPD nº 15/2024). |
| RFC 9700 (OAuth 2.0 Security BCP), RFC 9116 (security.txt) | `RFCn` | Protocol-level best practice. |

## The risk lists (what fails most)

| Reference | Sigil | Use it for |
|---|---|---|
| [OWASP Top 10:2025](https://owasp.org/Top10/2025/) | `T10:Ann` | Awareness and prioritisation. A01 Broken Access Control · A02 Security Misconfiguration · A03 Software Supply Chain Failures · A04 Cryptographic Failures · A05 Injection · A06 Insecure Design · A07 Authentication Failures · A08 Software or Data Integrity Failures · A09 Security Logging and Alerting Failures · A10 Mishandling of Exceptional Conditions. It is a list of risks, not a standard — "we cover the Top 10" is not a verification claim. |
| [OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/) | `API:APIn` | The API-specific failures, dominated by authorization: BOLA (API1), broken authentication (API2), property-level authorization (API3), unrestricted resource consumption (API4), function-level authorization (API5), sensitive business flows (API6), SSRF (API7), misconfiguration (API8), inventory (API9), unsafe consumption of third-party APIs (API10). |
| [CWE Top 25 (2025)](https://cwe.mitre.org/top25/) | `CWE-n` | The weaknesses behind the most CVEs last year — XSS, SQL injection and CSRF on top. CWE IDs are the lingua franca between scanners, advisories and this catalogue. |
| [OWASP Automated Threats to Web Applications](https://owasp.org/www-project-automated-threats-to-web-applications/) | `OAT:OAT-nnn` | The vocabulary for bots: credential stuffing, scraping, account creation, card testing, scalping, denial of inventory — 21 named threats. |
| [OWASP Top 10 for LLM Applications 2025](https://genai.owasp.org/llm-top-10/) | `LLM:LLMnn` | Prompt injection, output handling, excessive agency, unbounded consumption… |
| [OWASP Top 10 for Agentic Applications 2026](https://genai.owasp.org/) | `ASI:ASInn` | Goal hijack, tool misuse, identity and privilege abuse, agentic supply chain… |
| [CISA Known Exploited Vulnerabilities](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) | — | CVEs with confirmed exploitation in the wild. P11 blocks on any of them regardless of CVSS. |

## The attacker's view (how things are actually broken)

| Reference | Use it for |
|---|---|
| [OWASP Web Security Testing Guide (WSTG)](https://owasp.org/www-project-web-security-testing-guide/) | The pentester's procedure for each vulnerability class. The adversary pass (`REVIEW.md`) borrows its structure. |
| [PortSwigger Web Security Academy](https://portswigger.net/web-security) | The best free catalogue of web attack classes, each with explanation and labs — including the less famous ones (request smuggling, cache deception, OAuth flaws, prototype pollution, race conditions). |
| [MITRE ATT&CK](https://attack.mitre.org/) and [CAPEC](https://capec.mitre.org/) | Adversary tactics and attack patterns, for threat modelling and detection design. |
| [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security) and [HTTP Observatory](https://developer.mozilla.org/en-US/observatory) | Browser security features and an online grader for a site's headers. |
| [HackerOne Hacktivity](https://hackerone.com/hacktivity) | Real disclosed bug-bounty reports — what researchers actually find in SaaS products. |
| [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) | A deliberately vulnerable app to practise on and to calibrate tools against. |

## Incident data (why it matters)

| Reference | Use it for |
|---|---|
| [Verizon Data Breach Investigations Report](https://www.verizon.com/business/resources/reports/dbir/) | Yearly statistics on how breaches start: stolen credentials, exploited vulnerabilities, phishing, third parties. |
| Vendor post-mortems, CISA advisories, regulators' decisions (ICO, ANPD) | Primary sources for the cases in [`CASES.md`](CASES.md). |

## Crosswalk — catalogue domains to the main references

| Domain | ASVS 5.0 | Top 10:2025 | API Top 10 | Representative CWEs |
|---|---|---|---|---|
| 1 Input and injection | V1, V2, V5 | A05, A01 (SSRF) | API7 | 89, 78, 94, 502, 22, 611, 918, 1333 |
| 2 Browser and client side | V3, V12, V14 | A05, A02 | — | 79, 352, 601, 942, 1021, 829 |
| 3 Authentication | V6, V8 | A07 | API2 | 306, 307, 521, 640, 916 |
| 4 Sessions and SSO | V7, V9, V10 | A07 | API2 | 384, 598, 613, 347 |
| 5 Authorization and tenancy | V8 | A01 | API1, API3, API5 | 285, 639, 862, 602 |
| 6 Data, crypto, privacy | V11, V12, V14, V16 | A04, A10 | — | 319, 327, 338, 798, 209, 636 |
| 7 Availability, abuse, bots | V2, V4, V15 | — | API4, API6 | 400, 770, 799 |
| 8 Supply chain | V15 | A03, A08 | API10 | 1357, 1395, 829, 494 |
| 9 Configuration and infrastructure | V13 | A02 | API8, API9 | 284, 489, 732, 444 |
| 10 Files and uploads | V5 | A05 | — | 434, 22, 409 |
| 11 Business logic | V2 | A06 | API6 | 362, 841, 20 |
| 12 Detection and response | V16 | A09 | — | 778, 532 |
| 13 AI and LLM | — | — | — | LLM01–LLM10, ASI01–ASI10 |
| 14 Agent-built code | — | A06, A08 | — | — |
