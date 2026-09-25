# Domain 9 — Configuration, infrastructure and cloud

Security Misconfiguration rose to second place in the OWASP Top 10 (2025). The code can be flawless and the database still be open to the internet. Where infrastructure is declared as code, the gauntlet can read it; where it is not, this domain says what to record by hand.

---

### SEC-107 · Run production with secure defaults and nothing left over from development
`ASVS:V13` `CWE-489` `CWE-1188` `T10:A02` · verify: dast, iac · severity: high

Debug mode off, verbose errors off, default credentials changed, sample apps and test routes removed, admin consoles and API explorers not exposed, directory listing off, framework security features (CSRF protection, secure cookie defaults) left on.

### SEC-108 · Never expose datastores, caches, queues or admin ports to the internet
`ASVS:V13` `CWE-284` `T10:A02` · verify: iac · severity: critical

Databases, Redis, Elasticsearch, message brokers and SSH listen on private networks; security groups and firewalls deny by default. In 2017 tens of thousands of internet-reachable MongoDB and Elasticsearch instances without authentication were wiped and held for ransom within weeks.

### SEC-109 · Require IMDSv2 and block application access to cloud metadata
`ASVS:V13` `CWE-918` `T10:A01` · verify: iac · severity: high

Instance metadata requires session tokens (IMDSv2, hop limit 1) and containers that do not need it cannot reach it. This is the second line behind SEC-013 — the line that would have stopped the Capital One breach.

### SEC-110 · Keep object storage private by default
`ASVS:V13` `CWE-732` `T10:A02` · verify: iac, test · severity: critical

Account-level public-access blocks on; per-object access through signed URLs (SEC-066); Firebase and Supabase storage rules reviewed and tested like code. In 2025 the Tea dating-safety app leaked tens of thousands of users' selfies and identity documents from a storage bucket anyone could read.

### SEC-111 · Harden containers and the runtime
`ASVS:V13` `CWE-250` · verify: iac · severity: medium

Non-root user, read-only root filesystem, all Linux capabilities dropped and only needed ones added, no privileged mode, CPU and memory limits, minimal or distroless base images scanned for vulnerabilities.

### SEC-112 · Change infrastructure only through reviewed, scanned code
`ASVS:V13` `T10:A02` `CIS:4` · verify: iac · severity: medium

Terraform, CloudFormation, Kubernetes manifests, Dockerfiles and platform configuration live in the repository and are scanned (Trivy config, Checkov); console changes are detected as drift. A setting that exists only in someone's memory of a dashboard cannot be verified.

### SEC-113 · Separate environments and deny standing production access
`ASVS:V13` `CWE-653` · verify: config · severity: high

Production in its own cloud account or project, with its own credentials. Humans get time-limited, logged elevation; developer laptops and AI agents hold no production write credentials. The LastPass breach (2022) chained a compromised developer environment to a DevOps engineer's home computer to the production backups.

### SEC-114 · Keep an inventory of everything exposed
`ASVS:V13` `API:API9` `CIS:1` · verify: dast, adversary · severity: medium

Every hostname, API version, staging and preview deployment, and third-party service with your data. Old API versions and forgotten staging hosts keep old vulnerabilities alive; the inventory is the list the DAST check and the pentest (SEC-138) cover.

### SEC-115 · Protect domains and DNS
`ASVS:V13` `CWE-350` · verify: config · severity: high

No dangling CNAMEs pointing at deprovisioned cloud resources (subdomain takeover — an attacker claims the resource and serves content, and cookies scoped to the parent domain, on your subdomain); CAA records limiting who may issue certificates; registrar lock and MFA on the registrar account; DNSSEC where the provider supports it.

### SEC-116 · Authenticate outgoing email and forbid spoofing of your domains
`CWE-290` · verify: config · severity: medium

SPF, DKIM, and DMARC at `p=reject` for every domain, including domains that never send mail. Without it, the phishing email that "comes from" your app is indistinguishable from the real one.

### SEC-117 · Patch the platform on a schedule with a deadline
`ASVS:V15` `T10:A03` `CIS:7` · verify: sca, iac · severity: high

Operating systems, language runtimes, databases and managed services receive security updates within the same deadlines as dependencies (P11), and someone is subscribed to each vendor's security advisories.

### SEC-118 · Parse HTTP the same way at every hop
`ASVS:V4` `CWE-444` · verify: dast, config · severity: high

Reject requests with conflicting `Content-Length` and `Transfer-Encoding`, keep proxy and server HTTP stacks current, and avoid chains of proxies that disagree about where one request ends (request smuggling). Trust `X-Forwarded-*` headers only from your own edge.

### SEC-119 · Reach administrative interfaces only through private access
`ASVS:V13` `CWE-284` · verify: config · severity: high

Database consoles, queue dashboards, feature-flag and CMS admin panels, internal tools (SEC-047) sit behind a VPN or an identity-aware proxy, not on a public login page.
