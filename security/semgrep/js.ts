declare const db: any, prisma: any, sql: any, res: any, req: any, el: any, cp: any, win: any, jwt: any, cors: any, DOMPurify: any;
declare function exec(c: string): void;
declare function spawn(c: string, a: string[], o: object): void;
const id = req.query.id;

// ruleid: crivo.sec-001.sql-built-from-strings
db.query(`SELECT * FROM users WHERE id = ${id}`);
// ruleid: crivo.sec-001.sql-built-from-strings
db.query("SELECT * FROM users WHERE id = " + id);
// ruleid: crivo.sec-001.sql-built-from-strings
prisma.$queryRawUnsafe("SELECT 1");
// ok: crivo.sec-001.sql-built-from-strings
db.query("SELECT * FROM users WHERE id = $1", [id]);
// ok: crivo.sec-001.sql-built-from-strings
sql`SELECT * FROM users WHERE id = ${id}`;

// ruleid: crivo.sec-003.shell-with-input
cp.exec(`convert ${id} out.png`);
// ruleid: crivo.sec-003.shell-with-input
exec("ls " + id);
// ruleid: crivo.sec-003.shell-with-input
spawn("ls", [id], { shell: true });
// ok: crivo.sec-003.shell-with-input
spawn("ls", ["--", id], { shell: false });

// ruleid: crivo.sec-016.raw-html-sink
el.innerHTML = req.body.bio;
// ok: crivo.sec-016.raw-html-sink
el.innerHTML = "<b>static</b>";
// ok: crivo.sec-016.raw-html-sink
el.innerHTML = DOMPurify.sanitize(req.body.bio);
// ruleid: crivo.sec-016.raw-html-sink
el.insertAdjacentHTML("beforeend", req.body.bio);

// ruleid: crivo.sec-024.cors-reflects-origin
res.setHeader("Access-Control-Allow-Origin", req.headers.origin);
// ruleid: crivo.sec-024.cors-reflects-origin
cors({ origin: true, credentials: true });
// ok: crivo.sec-024.cors-reflects-origin
cors({ origin: ["https://app.batuvia.com"], credentials: true });

// ruleid: crivo.sec-026.cookie-flag-disabled
res.cookie("sid", "v", { httpOnly: false, secure: true });
// ok: crivo.sec-026.cookie-flag-disabled
res.cookie("__Host-sid", "v", { httpOnly: true, secure: true, sameSite: "lax" });

// ruleid: crivo.sec-027.open-redirect
res.redirect(req.query.next);
// ok: crivo.sec-027.open-redirect
res.redirect("/dashboard");

// ruleid: crivo.sec-028.postmessage-wildcard
win.postMessage({ token: 1 }, "*");
// ok: crivo.sec-028.postmessage-wildcard
win.postMessage({ ok: 1 }, "https://app.batuvia.com");

// ruleid: crivo.sec-050.credential-in-url
const handoff = `https://app.orpheus.com/start?token=${id}`;
// ok: crivo.sec-050.credential-in-url
const handoffCode = `https://app.orpheus.com/start?code=${id}`;

// ruleid: crivo.sec-051.jwt-not-verified
const claims = jwt.decode(req.cookies.t);
// ruleid: crivo.sec-051.jwt-not-verified
jwt.verify(req.cookies.t, "k", { algorithms: ["HS256", "none"] });
// ok: crivo.sec-051.jwt-not-verified
jwt.verify(req.cookies.t, "k", { algorithms: ["RS256"], audience: "orpheus" });

// ruleid: crivo.sec-068.tls-verification-disabled
const agentOpts = { rejectUnauthorized: false };
// ruleid: crivo.sec-068.tls-verification-disabled
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// ruleid: crivo.sec-070.insecure-random-secret
const resetToken = Math.random().toString(36).slice(2);
// ok: crivo.sec-070.insecure-random-secret
const jitter = Math.random() * 100;
