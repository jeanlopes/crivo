# Domain 13 — AI and LLM components

For products that call a language model (P09). A model reads instructions and data through the same channel, so any text it sees can try to take control of it. The references are the OWASP Top 10 for LLM Applications (2025) and the OWASP Top 10 for Agentic Applications (2026).

---

### SEC-140 · Treat every text the model reads as untrusted, and do not rely on the prompt for security
`LLM:LLM01` `ASI:ASI01` · verify: test, adversary · severity: critical

User messages, retrieved documents, web pages, emails, file contents, tool results and other agents' output can all carry injected instructions. No system prompt reliably prevents that. Security comes from what the model is *able* to do (SEC-142), not from what it is told. In 2025 "EchoLeak" showed a single crafted email making an enterprise copilot exfiltrate data without any click.

### SEC-141 · Treat model output as untrusted input to the next component
`LLM:LLM05` `CWE-94` `CWE-79` · verify: sast, test · severity: critical

Output rendered as HTML is encoded or sanitized (SEC-018); output used in SQL, shell, file paths or URLs goes through the same controls as user input (Domain 1); output is never passed to `eval`; structured output is validated against a schema before use.

### SEC-142 · Give the model the least agency that does the job
`LLM:LLM06` `ASI:ASI02` `ASI:ASI03` · verify: test, adversary · severity: critical

Tools run with the permissions of the user the model acts for, never with a service account that sees every tenant; read-only by default; irreversible or external actions (sending email, payments, deleting, sharing) require explicit human confirmation outside the model's control.

### SEC-143 · Close the exfiltration channels
`LLM:LLM02` · verify: headers, test · severity: high

A model that can emit Markdown images or links can leak data to an attacker's server in the URL. Do not auto-render remote images in model output (or restrict `img-src` in CSP to your origins), and give tools that fetch URLs an egress allow-list (SEC-013).

### SEC-144 · Keep secrets and other tenants' data out of prompts and indexes
`LLM:LLM02` `LLM:LLM07` `LLM:LLM08` · verify: test · severity: critical

System prompts are extractable — nothing in them may be secret. Retrieval filters by tenant and by the user's permissions *in the query*, not after it; embeddings of one customer's documents are never retrievable by another.

### SEC-145 · Bound what a user can make the model consume
`LLM:LLM10` `CWE-400` · verify: config, abuse · severity: high

Per-user and per-tenant limits on requests and tokens, a maximum output length, timeouts, and cost alerts (SEC-089). An LLM endpoint without limits is the most expensive endpoint in the system.

### SEC-146 · Pin models and verify what you load
`LLM:LLM03` `LLM:LLM04` `ASI:ASI04` · verify: sca, adversary · severity: high

Pin model versions; load weights only from trusted sources and in safe formats (safetensors, not pickle); record the provenance of fine-tuning and retrieval data, since poisoned data is a supply-chain attack.

### SEC-147 · Keep an adversarial evaluation set and ratchet it
`LLM:LLM01` `ASI:ASI01` · verify: test · severity: high

Prompt-injection, jailbreak, data-exfiltration and cross-tenant retrieval cases are part of the `llm-eval` dataset (P09), and their pass rate may not decrease — the same ratchet as every other LLM metric.
