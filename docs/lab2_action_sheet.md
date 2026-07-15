# Lab 2 Action Sheet - A security report has arrived

You are the maintainer of UploadGuard. A scanner has filed three findings against
your gem. Work this sheet **as a group**, in order.

> **Talk first. Touch the keyboard second.**

Read the report first: [`reports/scrutineer-upload_guard_workshop-20260715-upstream.md`](../reports/scrutineer-upload_guard_workshop-20260715-upstream.md)

**Setup gremlins are expected.** Every command's real output is printed on this
sheet. If your machine will not cooperate, read along - you lose nothing, and
nobody is behind. Flip your sticky note to orange and someone will come to you.

---

## The three claims

| # | Severity | Claim | Where |
|---|---|---|---|
| **#1** | **High** | Path traversal in `safe_filename`/`storage_path` → arbitrary file write | `lib/upload_guard_workshop.rb:60-65` |
| #2 | Medium | `content_type` allowlist and `image?`/`document?` trust client metadata | `lib/upload_guard_workshop.rb:68-79` |
| #3 | Medium | Extension allowlist substring-matches, accepting double extensions | `lib/upload_guard_workshop.rb:82-88` |

Three findings landing at once is a lot. Don't chase all three. **We take Finding
#1 together**; #2 and #3 are stretch cards once you're through the core.

---

## Step 1 - Predict (before you run anything)

The report says Finding #1 lets an upload escape the directory the host chose.
The host asked for `/srv/uploads/company_logos`.

**Write down one prediction as a group:**

> If Finding #1 is real, where will this upload actually be written?

Think about the trust flow: caller-controlled filename → `safe_filename` →
`storage_path` builds a path → the host writes there. Where does it land if
validation trusts the wrong thing?

**Commit it to paper before anyone runs anything.** The prediction is what turns
the next step into evidence-seeking rather than copy-paste.

---

## Step 2 - Reproduce Finding #1

```sh
bundle exec ruby -Ilib labs/lab2/reproduce_finding_1.rb
```

You are hunting **exactly two facts**:

1. **Did validation accept the upload?**
2. **Where did the resolved write target actually land?**

### Expected output

```
Finding #1 - path traversal in safe_filename/storage_path
Uploaded filename:     "../../../../tmp/uploads/../pwned.png"
Declared content type: image/png
Host's intended dir:   /srv/uploads/company_logos

== FACT 1 - does validation accept this upload? ==
validate.accepted? => true
validate.errors    => []

== FACT 2 - where does the write target land? (no files touched) ==
safe_filename    => "../../../../tmp/uploads/../pwned.png"
storage_path     => "/srv/uploads/company_logos/../../../../tmp/uploads/../pwned.png"
expanded         => "/tmp/pwned.png"
inside base_dir? => false

== Part B - end-to-end write, sandboxed in a temp directory ==
intended base_dir => /var/folders/.../upload_guard_lab2.../uploads/company_logos
actually wrote to => /var/folders/.../upload_guard_lab2.../pwned.png
escaped base_dir? => true
bytes on disk     => "OWNED_BYTES\n"
```

The script writes only inside a temporary directory that is deleted on exit.
Nothing on your machine is touched.

### The two facts, stated plainly

- **Validation accepted it.** `accepted? => true`, `errors => []`.
- **The write escaped.** The host asked for `/srv/uploads/company_logos`. The file
  resolves to **`/tmp/pwned.png`**.

**Did it match your prediction - supported, contradicted, or inconclusive?**

> **Accepted is not the same as safe.** The write target proves it.

### If your own payload got rejected - read this

Try `../../../../etc/passwd` and validation **rejects** it (`extension is not
allowed`). That does *not* make Finding #1 a false positive. The traversal has to
carry an allowed extension (`.png`, `.jpg`, `.jpeg`) to get past the extension
check - which is the only thing standing there. Finding #3 removes even that.
The stretch script shows the full chain.

**Don't jump to severity yet.** Get the two facts first.

---

## Step 3 - Triage the impact

**Write one sentence:**

> In what kind of app is this reachable, and what can an attacker do?

Work it in this order:

1. **Reachability first.** What would the surrounding app have to be doing? A
   controller or job that takes uploaded files, passes user-controlled filenames
   to the gem, and writes to `storage_path`'s result.
   → Now open [`examples/rails_controller.rb`](../examples/rails_controller.rb) line 35.
   **The gem ships that exact caller in its own examples directory.** This is not
   a contrived precondition.
2. **Is it real?** True positive, or false positive?
3. **How bad, really?** A scary label is not the same as reachable. What actually
   reaches this path in realistic use?

**Then choose your first move:**

| Move | When |
|---|---|
| **Fix** | It's real, reachable, and you can close it |
| **Mitigate** | You can reduce it now, fix it properly later |
| **Document** | The risk is the caller's to carry, and they need to know |
| **Dismiss** | It isn't real, or isn't reachable |

> **The one rule:** if you dismiss, **write down why** - and never dismiss
> something as "unreachable" without verifying it. A wrong dismissal is how a
> real vulnerability ships.

---

## Step 4 - Fix and verify

Patch `safe_filename` and `storage_path` in `lib/upload_guard_workshop.rb`.
Your patch has to keep **two promises**:

**Promise 1 - a filename stays a filename, never a path.**
Right now `safe_filename` strips NUL bytes and collapses whitespace, so `../`
sails straight through. Keep only the final component.

**Promise 2 - the final path stays under `base_dir`.**
Expand the joined path and confirm it's still inside before returning it.

> **Why both?** Ask your group: isn't `File.basename` enough on its own?
> Try `File.basename("..")` in `bin/console` before you answer.

### Then re-run the reproduction

```sh
bundle exec ruby -Ilib labs/lab2/reproduce_finding_1.rb
```

`inside base_dir?` should now be `true`, or the upload should be rejected
outright. The same input that escaped to `/tmp` should now stay contained.

> **A fix isn't a fix until you've re-run the repro and watched it fail safely.**

### Your test suite will go red - that's correct

```sh
bundle exec rake
```

Two tests in `test/test_workshop_vulnerability_baseline.rb` will now fail:

```
Expected: "../tenant-a/logo.png"
  Actual: "logo.png"
```

Those tests **assert the vulnerable behavior on purpose** - they pin the bug in
place. Your suite encoded the old promise. Rewriting them to assert the safe
behavior is the real last step of the fix.

---

## Step 5 - Draft your maintainer response

The fix isn't finished until the people relying on you know. Write four short
lines - there's a template at [`docs/lab2_advisory_draft.md`](lab2_advisory_draft.md).

- **Affected behavior:** what actually goes wrong?
- **Who is at risk:** which apps, doing what?
- **Immediate action:** what should users do right now?
- **What you will publish or send:** where does this go, and to whom?

---

## Finished early?

Pick one stretch card: [`docs/lab2_stretch_cards.md`](lab2_stretch_cards.md).
Finishing the core was already the win - there's no race.
