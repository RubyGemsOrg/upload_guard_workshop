# Lab 2 - Draft your maintainer response

You've reproduced Finding #1, judged its impact, and fixed it. **The loop isn't
closed yet.** A fix nobody knows about protects nobody.

This is a mock advisory page. Nothing here is published anywhere - fill it in as
a group, the way you'd fill in GitHub's "Report a vulnerability" → advisory draft.

---

## Part 1 - The four lines

Write one short line for each. Short is the point: this is what a downstream
maintainer skims at 5pm on a Friday.

### Affected behavior - what actually goes wrong?

> _(your line here)_

<details>
<summary>Stuck? A starting point</summary>

A caller-controlled filename is not stripped of path segments, so
`storage_path` can resolve outside the directory the host asked for. A host that
writes to that path writes attacker-controlled bytes to an arbitrary location.
</details>

### Who is at risk - which apps, doing what?

> _(your line here)_

<details>
<summary>Stuck? A starting point</summary>

Applications that pass user-controlled uploads to `Guard#storage_path` and write
the result to disk - the pattern shipped in `examples/rails_controller.rb`.
Applications that only call `validate` and never use `storage_path` are not
affected.
</details>

### Immediate action - what should users do right now?

> _(your line here)_

<details>
<summary>Stuck? A starting point</summary>

Upgrade to the patched version. If you can't upgrade today, confine the path in
your own code before writing: expand the joined path and reject anything that
doesn't sit under your intended upload directory.
</details>

### What you will publish or send - where does this go?

> _(your line here)_

<details>
<summary>Stuck? A starting point</summary>

A GitHub Security Advisory (GHSA) with a CVE requested, published once the
patched version is out; a release note pointing at the advisory; and a reply to
the reporter telling them what shipped and when.
</details>

---

## Part 2 - Advisory metadata

Fill these the way you'd fill the GHSA form.

| Field | Your answer |
|---|---|
| **Title** | |
| **Ecosystem / Package** | RubyGems / `upload_guard_workshop` |
| **Affected versions** | |
| **Patched version** | |
| **Severity** | |
| **CWE** | |
| **Credit** | |

<details>
<summary>What the report claimed - do you agree?</summary>

The scanner rated Finding #1 **High**, CWE-22 (Improper Limitation of a Pathname
to a Restricted Directory). Its reasoning: arbitrary file write with
attacker-controlled contents, escalating to RCE via a cron/config/`.rb` drop -
but not Critical, because it depends on the host writing to `storage_path`'s
output rather than firing on a fresh standalone install.

**You are the maintainer. The scanner's severity is an input, not the verdict.**
If you disagree, say so in the advisory and say why.
</details>

---

## Part 3 - Discuss

1. **How much detail?** Enough that users can assess their own exposure - but a
   working exploit published before people can upgrade helps attackers more than
   defenders. Where's your line?
2. **"Affected" is a promise.** If you say "all versions before 1.2", you're
   claiming you checked. Did you?
3. **Who else needs to hear this**, beyond the advisory? Direct dependents? A
   changelog? A post? The reporter?
4. **What if you can't fix it this week?** Is there an honest interim message -
   or does silence serve users better? (Look back at what your Lab 1
   `SECURITY.md` promised about response times. Can you keep it?)

---

> **The fix isn't finished until the people relying on you know.**
> That's what closes the loop.
