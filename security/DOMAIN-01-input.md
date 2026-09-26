# Domain 1 — Input and injection

Everything that crosses a trust boundary is data until proven otherwise. Injection happens when data reaches an interpreter — SQL, a shell, a template, a parser, a regex engine, a URL fetcher — and is read as instructions.

---

### SEC-001 · Parameterize every database query; never build SQL from strings
`ASVS:V1` `CWE-89` `T10:A05` · verify: sast, dast, fuzz, abuse · severity: critical

ORMs are safe until someone reaches for `raw()`, `$queryRawUnsafe`, `knex.raw`, or a template literal passed to `query()`. Identifiers (sort column, table name) cannot be bound as parameters: map them from an allow-list. Test: every search, filter and sort parameter receives `' OR '1'='1`, `1;SELECT pg_sleep(5)--` and an unknown column name in an `@security` scenario; the response is a 4xx or an empty result, never a 500 and never a 5-second delay.

### SEC-002 · Reject query operators in user input sent to NoSQL stores
`ASVS:V1` `CWE-943` `T10:A05` · verify: sast, test · severity: critical

`{"password": {"$ne": null}}` logs in as anyone on MongoDB; `?user[$ne]=x` does the same through query-string parsers that build objects. Validate that fields expected to be strings are strings before they reach the query.

### SEC-003 · Never pass input to a shell; call programs with an argument array
`ASVS:V1` `CWE-78` `T10:A05` · verify: sast · severity: critical

`exec("convert " + name)` is remote code execution. Use `execFile`/`spawn` with `shell: false` (Node) or `subprocess.run([...])` (Python), and put `--` before user-supplied arguments so they cannot be read as options.

### SEC-004 · Never evaluate input as code, including templates
`ASVS:V1` `CWE-94` `CWE-1336` `T10:A05` · verify: sast · severity: critical

`eval`, `new Function`, `setTimeout(string)`, `vm.runInContext`, and compiling a template whose source came from a user (server-side template injection) all hand the attacker the runtime. User-editable templates use a logic-less engine in a sandbox.

### SEC-005 · Deserialize data formats only, never object graphs from untrusted sources
`ASVS:V1` `CWE-502` `T10:A08` · verify: sast · severity: critical

`pickle.loads`, `yaml.load` without a safe loader, `node-serialize`, Java native serialization and `BinaryFormatter` instantiate attacker-chosen types. Use JSON with a schema. Signed payloads (cookies, cached blobs) are still parsed as data.

### SEC-006 · Resolve file paths under a fixed root and reject anything that escapes it
`ASVS:V5` `CWE-22` `T10:A01` · verify: sast, test · severity: high

Canonicalize (`path.resolve`, `Path.resolve()`), then check the prefix. `../`, absolute paths, URL-encoded and double-encoded separators, and null bytes all appear in the wild. Better: never use a user-supplied name as a path — look the file up by an ID.

### SEC-007 · Disable external entities and DTD processing in every XML parser
`ASVS:V1` `CWE-611` `T10:A02` · verify: sast · severity: high

XML hides in SVG uploads, DOCX/XLSX, SAML and SOAP. An enabled external entity reads local files or triggers SSRF (SEC-013).

### SEC-008 · Validate every input server-side against a schema at the boundary
`ASVS:V2` `CWE-20` · verify: test, fuzz · severity: high

Type, length, range, format and allow-listed values, checked once at the edge with a schema library (zod, pydantic, JSON Schema) and rejected with a 4xx. Client-side validation is user experience, not security. Fuzzing the API from its OpenAPI schema is the cheapest way to find the fields nobody validated.

### SEC-009 · Bind request bodies to explicit input types; never mass-assign into models
`ASVS:V2` `CWE-915` `API:API3` · verify: sast, test · severity: high

`User.update(req.body)` lets the caller set `role`, `isAdmin`, `tenantId`, `emailVerified` or `price`. In 2012 a GitHub user added his key to the Rails organisation exactly this way. The input DTO lists what may be written; everything else is dropped or rejected.

### SEC-010 · Block prototype pollution in JavaScript
`ASVS:V1` `CWE-1321` · verify: sast, sca · severity: high

Recursive merge, `set(obj, path, value)` helpers and naive query-string parsers let `__proto__`, `constructor` and `prototype` keys change every object in the process — often leading to authorization bypass or RCE via gadgets. Reject those keys, build lookups with `Map` or `Object.create(null)`, and keep merge libraries patched.

### SEC-011 · Strip CR and LF from anything placed in headers, emails or log lines
`ASVS:V1` `CWE-93` `CWE-113` `CWE-117` · verify: sast, test · severity: medium

Response splitting, email header injection (`Bcc:` added through a name field), and forged log entries all start with a newline in user input. Structured (JSON) logging removes most of the log case.

### SEC-012 · Bound the cost of every regular expression that sees user input
`ASVS:V1` `CWE-1333` · verify: sast, fuzz · severity: high

Catastrophic backtracking turns one request into minutes of CPU. A single WAF regex took Cloudflare down worldwide in July 2019; one post took Stack Overflow down in 2016. No user-supplied patterns; no nested quantifiers on untrusted text; prefer linear-time engines (RE2, `re2` bindings) and cap input length before matching.

### SEC-013 · Fetch server-side URLs only through an egress client that blocks internal destinations
`ASVS:V1` `CWE-918` `T10:A01` `API:API7` · verify: sast, test, iac · severity: critical

Webhooks, link previews, image-by-URL, PDF renderers and import-from-URL features are SSRF. The client resolves DNS, rejects loopback, private, link-local and cloud-metadata ranges (169.254.169.254, fd00:ec2::254), re-checks after every redirect, and pins the resolved IP for the connection (DNS rebinding). Capital One lost 100 million records in 2019 through SSRF to the metadata service.

### SEC-014 · Encode output for the exact context it lands in
`ASVS:V1` `CWE-116` `T10:A05` · verify: sast, adversary · severity: high

HTML body, HTML attribute, JavaScript string, URL, CSS, SQL, shell and LDAP each need a different encoder. Encoding for the wrong context is the same as not encoding. Frameworks do the HTML case automatically (SEC-016); everything else is manual and deserves a `RULE-` pointer.

### SEC-015 · Canonicalize before validating
`ASVS:V2` `CWE-180` · verify: test · severity: medium

Decode once, normalize Unicode (NFKC for identifiers), lower-case with a locale-independent function, then validate and compare. Unicode case-mapping collisions (a dotless `ı` that upper-cases to `I`) have delivered password-reset emails to the wrong account. Store and compare the canonical form of emails and usernames.

### SEC-016 · Rely on auto-escaping templates; every raw-HTML escape hatch is a finding
`ASVS:V1` `ASVS:V3` `CWE-79` `T10:A05` · verify: sast, lint · severity: high

`dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `insertAdjacentHTML`, `bypassSecurityTrust*`, Jinja `|safe`, Handlebars `{{{ }}}`, `mark_safe`. Each occurrence must pass through a sanitizer (SEC-018) and carry a `RULE-` reference. XSS is the first entry of the 2025 CWE Top 25.

### SEC-017 · Neutralize spreadsheet formulas in CSV and XLSX exports
`ASVS:V1` `CWE-1236` · verify: test · severity: medium

A cell that starts with `=`, `+`, `-`, `@`, tab or carriage return runs as a formula when an admin opens the export. Prefix those cells with `'` or reject them at input.
