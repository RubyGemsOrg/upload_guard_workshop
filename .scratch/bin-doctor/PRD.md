# PRD: Portable environment doctor

Status: ready-for-agent

## Problem Statement

Workshop attendees need a quick, trustworthy way to determine whether their local environment is ready to run the UploadGuard library and its tests. Today, setup problems surface only after attendees try Bundler or the full test task, which mixes environment failures with library or test failures and makes remediation harder. Attendees may use different Ruby version managers—or no version manager at all—so the diagnosis must evaluate the active environment without assuming a particular toolchain.

## Solution

Provide a portable `bin/doctor` command that performs read-only, end-to-end readiness checks and reports all useful results in one run, in the spirit of `brew doctor`. It will inspect the active Ruby and Bundler environment, confirm that the installed dependencies are complete, and perform a minimal library-load smoke check without running tests, installing software, using the network, or modifying files.

The command will print clear successes, failures, skipped checks, and actionable remedies. It will exit successfully only when the environment is ready, then direct the attendee to run the full test and lint task separately.

## User Stories

1. As a workshop attendee, I want one command that checks my environment, so that I can resolve setup problems before the workshop exercise begins.
2. As a workshop attendee, I want the command to detect whether Ruby is available on `PATH`, so that a missing Ruby installation produces a clear diagnosis instead of a shell error.
3. As a workshop attendee, I want to see which Ruby executable is active, so that I can spot an incorrectly selected system Ruby or version-manager configuration.
4. As a workshop attendee, I want to see the active Ruby version, so that I know which runtime the workshop will use.
5. As a workshop attendee, I want the active Ruby checked against the library's declared requirement, so that readiness matches the library's actual support contract.
6. As a maintainer, I want the minimum Ruby requirement derived from the gem specification, so that the doctor stays aligned when supported versions change.
7. As an attendee using rbenv, asdf, chruby, mise, or another tool, I want the doctor to inspect the active Ruby rather than require a particular version manager, so that the workshop remains portable.
8. As a workshop attendee, I want the doctor to detect whether Bundler is available and runnable, so that missing or incompatible Bundler installations receive a targeted remedy.
9. As a workshop attendee, I want the doctor to account for the Bundler version selected by the lockfile, so that an unusable locked bundle is not reported as healthy.
10. As a workshop attendee, I want the doctor to check whether all bundle dependencies are installed, so that I know whether I need to run `bundle install`.
11. As a workshop attendee, I want a minimal library-load check through Bundler, so that installed dependencies, the active Ruby, and the library are proven to work together.
12. As a workshop attendee, I want the doctor to remain read-only, so that diagnosis never makes unexpected changes to my machine or checkout.
13. As a workshop attendee, I want the doctor to avoid network access, so that it works after dependencies have been installed and does not pause for downloads.
14. As a workshop attendee, I want the doctor to gather every independent failure in one run, so that I can fix several setup problems at once.
15. As a workshop attendee, I want dependent checks clearly marked as skipped when a prerequisite is unavailable, so that skipped work is not confused with a passing result.
16. As a workshop attendee, I want each failure to include a practical next step, so that I do not need prior Ruby tooling knowledge to recover.
17. As a workshop attendee, I want the command to exit nonzero when any required check fails, so that its readiness result is reliable for scripts as well as people.
18. As a workshop attendee, I want a concise success summary that names the full test command, so that I know what to do next.
19. As a workshop attendee, I want to invoke the doctor from outside the repository root, so that its behavior does not depend on my current directory.
20. As a workshop facilitator, I want setup documentation to introduce the doctor and explain its purpose, so that all attendees follow the same diagnostic path.
21. As a workshop facilitator, I want the setup and doctor commands to remain separate, so that installing dependencies is not confused with diagnosing readiness.
22. As a maintainer, I want the doctor to check only real library and test prerequisites, so that unrelated tools such as Git, PostgreSQL, or external services do not create false failures.
23. As a maintainer, I want the full test and lint task kept outside the doctor, so that environment diagnosis remains fast and test failures retain their own meaning.
24. As a maintainer, I want the script to use portable shell behavior, so that it works on typical macOS and Linux workshop machines without extra scripting dependencies.

## Implementation Decisions

- The public interface is an executable `bin/doctor` command implemented as a POSIX `sh` script. It cannot be implemented solely in Ruby because it must provide a friendly diagnosis when Ruby itself is missing.
- The command is strictly read-only. It must not install Ruby, install gems, update the bundle, change configuration, write project files, or contact the network.
- The command resolves the project root relative to its own location and runs project-specific checks there. Its behavior must not depend on the caller's current working directory.
- Ruby is discovered through `PATH`. A healthy result reports both the selected executable and its version.
- The gem specification is the source of truth for the supported Ruby requirement. Any active Ruby satisfying that requirement is acceptable; no version manager is required or preferred.
- Bundler readiness has two layers: the `bundle` command must be available and runnable, and the current bundle must pass Bundler's dependency completeness check. Errors caused by the lockfile's selected Bundler version are reported as Bundler failures with the relevant remedy.
- Library readiness is checked with a minimal require operation executed through Bundler against the local library source. This is a smoke check only; it must not exercise the test suite or workshop behavior.
- Checks accumulate results rather than failing fast. Independent checks continue after a failure, while checks whose prerequisites are unavailable are reported as skipped.
- Required failures produce a nonzero exit status. A fully healthy environment produces exit status zero.
- Output is human-readable and inspired by `brew doctor`: it distinguishes passing, failing, and skipped checks; retains useful underlying error context; and provides an actionable next step for every failure.
- A successful run ends by telling the user that the environment is ready and directing them to run `bundle exec rake` for the full tests and lint.
- Ruby, Bundler, installed bundle dependencies, and successful library loading are the complete readiness boundary. Git, a database, external services, network connectivity, and a specific version manager are not requirements.
- Setup documentation will introduce the doctor as the first diagnostic command and state that it is read-only. The existing setup command remains unchanged and continues to own dependency installation.
- No schema, public Ruby API, workshop vulnerability behavior, dependency, or release-safety change is part of this work.

## Testing Decisions

- The single testing seam is the doctor command's external behavior: its human-readable output and process exit status. No internal shell function or implementation detail should be tested independently.
- Verification is manual, matching the agreed scope; this PRD does not introduce a new automated doctor test harness.
- Manual verification will exercise a healthy environment plus controlled failure scenarios for missing Ruby, unsupported Ruby, unavailable or unusable Bundler, an incomplete bundle, and a failed library load.
- Each failure scenario must demonstrate that independent checks continue, dependent checks are marked skipped, the process exits nonzero, and the output includes a useful remedy.
- The healthy scenario must demonstrate that the command can be invoked from outside the repository root, performs no writes, exits zero, and directs the user to `bundle exec rake`.
- After manual doctor verification, the repository's existing highest-level default task will be run to confirm that the full test suite and lint remain green.
- Existing command-level subprocess assertions around publication safeguards provide prior art for evaluating exit status and user-visible command behavior, even though no new automated coverage is required here.

## Out of Scope

- Installing, upgrading, or selecting Ruby.
- Requiring, installing, or configuring mise, rbenv, asdf, chruby, or another version manager.
- Installing or updating Bundler or project dependencies.
- Running the test suite or RuboCop from the doctor command.
- Checking Git, PostgreSQL, databases, containers, browsers, network connectivity, or external services.
- Repairing the checkout or changing project configuration.
- Changing the existing setup command.
- Adding automated tests specifically for the doctor command.
- Changing the library API, intentional workshop vulnerabilities, fixtures, release safeguards, or supported Ruby requirement.

## Further Notes

- The command is a readiness diagnostic, not proof that the library's behavioral tests pass. It deliberately ends where `bundle exec rake` begins.
- Remedies should preserve the attendee's freedom to use any Ruby installation strategy. Messages may state the required version or command to run, but should not prescribe one version manager.
- The implementation must preserve the workshop repository's anti-publication posture and must not add publishing or release behavior.
