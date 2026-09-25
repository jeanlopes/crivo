import os, pickle, random, subprocess, yaml, jwt, requests, secrets
from sqlalchemy import text

def handlers(cur, uid, cmd, blob, tok):
    # ruleid: crivo.sec-001.sql-built-from-strings
    cur.execute(f"SELECT * FROM users WHERE id = {uid}")
    # ruleid: crivo.sec-001.sql-built-from-strings
    cur.execute("SELECT * FROM users WHERE id = %s" % uid)
    # ruleid: crivo.sec-001.sql-built-from-strings
    text(f"SELECT * FROM users WHERE id = {uid}")
    # ok: crivo.sec-001.sql-built-from-strings
    cur.execute("SELECT * FROM users WHERE id = %s", (uid,))

    # ruleid: crivo.sec-003.shell-with-input
    subprocess.run(cmd, shell=True)
    # ruleid: crivo.sec-003.shell-with-input
    os.system("convert " + cmd)
    # ok: crivo.sec-003.shell-with-input
    subprocess.run(["convert", "--", cmd])

    # ruleid: crivo.sec-005.unsafe-deserialization
    pickle.loads(blob)
    # ruleid: crivo.sec-005.unsafe-deserialization
    yaml.load(blob)
    # ok: crivo.sec-005.unsafe-deserialization
    yaml.load(blob, Loader=yaml.SafeLoader)

    # ruleid: crivo.sec-050.credential-in-url
    link = f"https://app.batuvia.com/enter?access_token={tok}"
    # ok: crivo.sec-050.credential-in-url
    link = f"https://app.batuvia.com/enter?code={tok}"

    # ruleid: crivo.sec-051.jwt-not-verified
    jwt.decode(tok, options={"verify_signature": False})
    # ok: crivo.sec-051.jwt-not-verified
    jwt.decode(tok, "k", algorithms=["RS256"], audience="batuvia")

    # ruleid: crivo.sec-068.tls-verification-disabled
    requests.get("https://example.com", verify=False)

    # ruleid: crivo.sec-070.insecure-random-secret
    reset_token = str(random.random())
    # ok: crivo.sec-070.insecure-random-secret
    reset_token = secrets.token_urlsafe(32)
    # ok: crivo.sec-070.insecure-random-secret
    delay = random.uniform(0, 1)
    return link, reset_token, delay
