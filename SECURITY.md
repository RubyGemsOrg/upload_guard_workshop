# Security Policy

<!--
  WORKSHOP EXERCISE — read this before you start.

  This file is a draft security policy for UploadGuard. Every section below offers two or three options. None of them are wrong; each one is a choice real maintainers make, with real tradeoffs.

  In your group, work through the sections in order:

    1. Read the "Discuss" prompt and talk it through.
    2. Pick the option your group would actually adopt for this gem — a small library maintained by one or two volunteers.
    3. Delete the options you didn't pick, and delete the Discuss prompt.

  When you're done, this file should read as a complete, real SECURITY.md that you'd be comfortable shipping with the gem.
-->

## Reporting a Vulnerability

> **Discuss:** Who reads the report first, and what happens if that person is on holiday for three weeks? How fast can you honestly promise to respond?

**Option A — Private email alias**

Report vulnerabilities to `security@uploadguard.invalid`. Do not open a public issue. We will acknowledge your report within 3 business days and aim to give you an initial assessment within 14 days.

**Option B — GitHub Private Vulnerability Reporting**

Use the "Report a vulnerability" button under this repository's Security tab. Reports are triaged as they arrive; you can expect a first response within a week. Please do not open a public issue for suspected vulnerabilities.

**Option C — Public issue tracker**

Open a regular GitHub issue. We are a small project and believe fast, public reports serve our users better than slow, private ones: most issues in a validation library are misuse hazards rather than remotely exploitable bugs, and public discussion gets them fixed sooner.

## Supported Versions

> **Discuss:** Every version you promise to patch is a promise to maintain a release branch, backport a fix, and cut a release under time pressure. How many of those promises can a volunteer keep?

**Option A — Latest release only**

Only the most recent release receives security fixes. If you are on an older version, upgrade before reporting; we will not backport patches.

**Option B — Current major version**

All releases within the current major version receive security fixes. Older major versions are end-of-life and will not be patched, though we will note in the advisory whether they are affected.

**Option C — Time-windowed support**

Releases receive security fixes for 12 months after their release date. The advisory for each fix lists which released versions are affected and which patched versions to upgrade to.

## Disclosure Timeline

> **Discuss:** A deadline protects users from a maintainer who sits on a bug — but it also starts a clock on a volunteer's spare time. Who should hold the clock, the reporter or the maintainer?

**Option A — Fixed embargo**

We follow a 90-day coordinated disclosure window. From the day a report is acknowledged, we have 90 days to release a fix before the reporter may publish details, whether or not a fix has shipped. We may agree to publish earlier once a fix is out.

**Option B — Coordinated, case by case**

We work with the reporter to agree on a disclosure date that fits the severity of the issue and the complexity of the fix. We ask reporters not to publish details until a patched release is available and users have had a reasonable window to upgrade.

**Option C — Fix first, then full disclosure**

We publish full details — including the vulnerable code and exploit conditions — as soon as a fixed version is released. We believe users of a security-adjacent library deserve enough detail to judge their own exposure, and that obscurity after a patch protects no one.

## Scope

> **Discuss:** Where does this library's responsibility end and the host application's begin? A generous scope earns trust but buries a solo maintainer in reports; a narrow one closes reports fast but may close the wrong ones.

**Option A — Broad scope**

Any input that causes UploadGuard to approve something it should reject, or to misbehave in a way an attacker could influence, is in scope — even if it requires unusual configuration or an application passing us unvalidated data. If our API makes the insecure path easy, that is our bug.

**Option B — Documented-use scope**

Issues are in scope when they occur under documented usage. If an application bypasses documented requirements — for example by passing values the documentation says must already be sanitized — that is an application bug, and we will close the report with an explanation rather than a fix.

**Option C — Vulnerabilities, not hardening**

In scope: flaws exploitable by an attacker under realistic conditions. Out of scope: hardening suggestions, missing defense-in-depth, and issues requiring an already-compromised host or a hostile application developer. Hardening ideas are welcome — as regular issues, not security reports.

## Triage & Severity

> **Discuss:** A CVSS score looks objective, but someone still chooses the inputs. Does a number help a small project, or does it just decorate a judgment call?

**Option A — CVSS scoring**

Each confirmed report is assigned a CVSS v3.1 base score, which determines the advisory's severity rating and how urgently we cut a release. The score and vector string are published in the advisory so users can re-score for their own environment.

**Option B — Severity buckets**

We rate confirmed reports as Critical, High, Medium, or Low based on impact and how likely real applications are to be affected. Critical and High issues trigger an out-of-band release; Medium and Low issues ship with the next regular release.

**Option C — Maintainer judgment**

We triage each report on its own terms: how exploitable it is, how many users are realistically affected, and how disruptive the fix is. Each advisory explains our reasoning in plain language instead of assigning a score.

## Credit

> **Discuss:** What can a project with no budget actually offer a reporter — and does promising anything create an obligation you can't always meet?

**Option A — Public acknowledgment**

Reporters of confirmed vulnerabilities are credited by name (or handle) in the security advisory, the release notes, and this repository's acknowledgments list, unless they ask to remain anonymous. Where a CVE is assigned, the reporter is credited in it.

**Option B — Thanks, case by case**

We are grateful for reports and will happily credit reporters in advisories on request, but we make no standing commitments. We are a volunteer project and do not run a bounty program.

**Option C — Explicit no-reward statement**

We do not offer bounties, swag, or rewards of any kind, and we ask reporters not to condition disclosure on payment. Confirmed reports are credited in the advisory. We state this up front so expectations are clear before anyone invests time in a report.
