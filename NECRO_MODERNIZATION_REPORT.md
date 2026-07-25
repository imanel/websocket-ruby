# websocket-ruby Modernization Report

This branch modernizes `websocket-ruby` for current Ruby (target: **4.0.6**, the
newest release) and brings the development toolchain, test coverage, docs and
lint setup up to current standards. The library itself has **zero runtime
dependencies**, which kept this scoped almost entirely to dev tooling, test
coverage and documentation — the production code needed no behavioral changes
to run correctly on Ruby 4.0.6.

## TL;DR

- Full test suite (1233 examples) passes on Ruby 4.0.6.
- Test coverage raised from ~96% lines / ~79% branches to **100% lines / 100%
  branches** (enforced going forward via SimpleCov's `minimum_coverage`).
- RuboCop upgraded from 0.52.1 (2018) to 1.88.2 and the repo passes with zero
  offenses.
- `bundler-audit` reports no known vulnerabilities in any dependency.
- Replaced an abandoned, unpinned third-party GitHub Action in the release
  workflow with a plain `gem build`/`gem push` step.
- Added/refreshed YARD documentation across previously undocumented classes
  and methods.
- No `blocked` conditions were hit — everything in the task list was completed.

## 1. Dependencies

The gemspec has **no runtime dependencies** (this is a pure-Ruby protocol
library), so this section is entirely about the `Gemfile` dev group.

| Gem | Before | After |
|---|---|---|
| `rspec` | `~> 3.7` (resolved to old 3.x) | `~> 3.13` |
| `rubocop` | pinned `0.52.1` (2018, pre-dates `Layout/*` cop reorganization) | `~> 1.88` |
| `rubocop-rspec` | pinned `1.21.0` | `~> 3.10` |
| `rake` | unpinned | `~> 13.0` |
| `webrick` | unpinned | `~> 1.9` |
| `simplecov` | *(not present)* | `~> 1.0` *(added)* |
| `bundler-audit` | *(not present)* | `~> 0.9` *(added)* |

The old `Gemfile` pinned RuboCop to `0.52.1` specifically "to match Code
Climate" — that pin, and the corresponding `channel: rubocop-0-52` in
`.codeclimate.yml`, are seven years stale and no longer meaningful, so both
were removed/updated.

No gem in the dependency tree had a known-abandoned or dead upstream — all
upgrades are to current, actively maintained major versions of the same
gems. `bundler-audit`'s advisory database (synced during this session)
reports **zero vulnerabilities** for the resulting dependency set.

### CI/CD

- `.github/workflows/test.yml`: bumped `actions/checkout` from `v2` (uses an
  EOL Node.js runtime) to `v4`, bumped the RuboCop job's Ruby to `3.3` (needed
  to run modern RuboCop), and added `"4.0"` to the test matrix.
- `.github/workflows/publish.yml`: replaced
  `cadwallion/publish-rubygems-action@master` with a plain
  `gem build && gem push` step using only official, maintained actions
  (`actions/checkout@v4`, `ruby/setup-ruby@v1`). The old action was:
  - unmaintained (no meaningful activity in years),
  - pinned to a floating `@master` ref, which is a supply-chain risk (an
    arbitrary future commit to that repo would run unreviewed in CI with
    publish credentials).

  The replacement has no third-party action in the trust chain for the
  publish step itself.

## 2. Ruby 4.0.6 compatibility

The existing code already ran cleanly on Ruby 4.0.6 — the full suite passed
with zero failures and zero `-w` warnings before any changes were made. No
removed-stdlib, deprecated-API or frozen-string issues were found (the CHANGELOG
shows the previous maintainer had already dealt with `base64`, Ruby 3.4, etc.
in prior releases).

Changes made for explicit version declaration and matrix coverage:

- Added `.ruby-version` = `4.0.6`.
- Raised `required_ruby_version` from `>= 2.0` (a floor the CI matrix didn't
  even test) to `>= 2.1`, matching the oldest Ruby actually exercised by CI.
  The library has no syntax or stdlib dependency newer than that, so no
  broader support was dropped.
- Added Ruby `4.0` to the CI test matrix (`test.yml`).

## 3. Tests & coverage

Added SimpleCov (`spec/spec_helper.rb`) with branch coverage enabled and
`minimum_coverage line: 100, branch: 100` so the suite now fails if coverage
regresses.

**Coverage before:** 96.19% lines / 78.64% branches (840 relevant lines / 206
branches, measured with the same SimpleCov config immediately after adding
it, before any new specs).
**Coverage after:** **100.00% lines / 100.00% branches** (868 lines / 206
branches — some lines shifted as RuboCop's safe autocorrect added required
blank lines after guard clauses).

18 new spec files were added and ~20 existing spec files gained new
examples/contexts (1233 total examples now, up from 1028), including:

- **Protocol edge cases** that were previously reachable but untested:
  reserved-bit violations, fragmented control frames, a data frame sent
  mid-continuation, over-long control-frame payloads, invalid UTF-8 spanning
  a continuation frame, incomplete extended-length headers (16-bit and
  64-bit), hixie-75 length-prefixed framing (incomplete header/payload,
  multi-byte varint lengths, oversized lengths), and outgoing close frames
  with invalid custom codes.
- **Handshake edge cases**: missing host, unknown protocol version (both
  frame- and handshake-level, client and server), malformed request/status
  lines, repeated `Sec-WebSocket-Protocol` header merging, the legacy
  `Sec-WebSocket-Draft` header fallback, `Rack` input fallback chain
  (`#readpartial` → `#read` → `#to_s`), and the hixie-76 32-bit key overflow
  check.
- **Directly-verified defensive/abstract code** where black-box protocol
  crafting can't reach a branch (e.g. `WebSocket::Frame::Base#supported_frames`
  and `Handler::Base#encode_frame`/`#decode_frame`, which are abstract
  `NotImplementedError` stubs never called through the public API since every
  concrete subclass overrides them). These are tested directly against the
  class rather than simulated through protocol bytes, which is noted in each
  spec so it's clear they test the contract, not a reachable runtime path.
- A `spec/error_spec.rb` that reflectively walks every `WebSocket::Error`
  subclass and asserts each exposes a symbolic `#message` — this exercises
  every error class's `#message` method (several of which represent fairly
  obscure protocol violations) without hand-crafting a triggering byte
  sequence for each one, and will automatically cover any error class added
  in the future.

One existing autocorrect footgun is worth flagging for future maintainers:
running `rubocop -A` renamed `@frame_type` to `@decode_continuation_frame`
inside `Handler03#decode_continuation_frame` (RuboCop's
`Naming/MemoizedInstanceVariableName`, applied "unsafely"). That variable is
intentionally *shared* state read later by `decode_finish_continuation_frame`,
not a per-method memoization — the autocorrect broke 20 examples. It's fixed
in code and the cop is now excluded for that file with a comment explaining
why, so `rubocop -A` stays safe to run again.

## 4. Documentation

Added YARD-style documentation to every previously-undocumented public class
and several methods, including:

- All five `Frame::Handler::Handler0{3,4,5,7}`/`Handler75` classes (each now
  states which protocol drafts it implements and what's distinct about its
  framing).
- `Frame::Incoming::Client`/`Server` and `Frame::Outgoing::Client`/`Server`
  (the masking-direction methods now explain the RFC 6455 rule they encode:
  client→server frames must be masked, server→client frames must not be).
- All `Handshake::Handler::Client*`/`Server*` version classes.
- Every leaf class in `WebSocket::Error` now has a one-line comment
  explaining the condition that triggers it — previously this 130-line file
  had no documentation at all beyond the symbol names.
- `WebSocket.load_native_extension` (see below).

README setup instructions were checked and are still accurate (the gem has
no dependencies and no build step); no changes were needed there.
`CHANGELOG.md`'s `## Edge` section was filled in with this branch's changes,
matching the project's existing changelog convention.

## 5. Lint

`.rubocop.yml` was updated for RuboCop 1.88 / rubocop-rspec 3.10:

- `require: rubocop-rspec` → `plugins: [rubocop-rspec]` (the old `require:`
  form now prints a migration warning).
- `Layout/IndentHeredoc` (renamed to `Layout/HeredocIndentation` years ago)
  and `Metrics/LineLength` (moved to `Layout/LineLength`) references fixed.
- `NewCops: disable` and `SuggestExtensions: false` added, so upgrading
  RuboCop again in the future won't silently start failing CI on newly
  introduced cops.
- A handful of narrowly-scoped, justified exclusions added (each with an
  inline comment): `Naming/VariableNumber` for the protocol-draft-numbered
  spec helpers (`client_handshake_76`, etc. — the numbers are protocol
  versions, not counters), `RSpec/NoExpectationExample` for two shared
  examples that assert via a `validate_request` helper method (a RuboCop
  blind spot, not a real gap), `RSpec/MultipleMemoizedHelpers` disabled
  (this suite's parametrized shared-example style relies on many `let`s by
  design), and `Naming/MemoizedInstanceVariableName` excluded for the one
  file where it's actively wrong (see above).

Ran `rubocop -A` (including unsafe autocorrects) once, reviewed every
resulting diff hunk by hand, and fixed the one behavioral regression it
introduced. The full 80-file codebase (lib + spec) now passes
`rubocop` with **zero offenses**.

## 6. Security

- `bundler-audit check --update` (synced ruby-advisory-db, 1218 advisories at
  time of this run): **no vulnerabilities found** in any dependency.
- Reviewed the codebase for common risk patterns: no `eval`/`instance_eval`/
  `class_eval`/`Marshal.load`/`YAML.load`/shell-out usage anywhere in `lib/`.
- Reviewed every `Regexp` used against untrusted (network) input for
  catastrophic-backtracking risk (header parsing, status-line/request-line
  parsing, hixie framing). All are linear/anchored with no nested/overlapping
  quantifiers — no ReDoS exposure found.
- Replaced the release workflow's unpinned, unmaintained third-party GitHub
  Action (`cadwallion/publish-rubygems-action@master`) — see "CI/CD" above.
  This is the one concrete supply-chain risk found in the repo; it's now
  gone.
- `Digest::MD5` and `Digest::SHA1` are used in the hixie-76 and RFC 6455
  handshake challenge/response respectively. This looks like a classic
  "weak hash" finding, but both are **mandated by the protocol
  specifications themselves** (RFC 6455 §4.2.2 requires SHA-1 for
  `Sec-WebSocket-Accept`; the hixie-76 draft requires MD5 for its challenge).
  They aren't used for anything security-sensitive (password hashing,
  signing, etc.) — just as protocol-specified identifiers — so no change was
  made; "fixing" this would break interoperability with every real
  WebSocket implementation.
- `Handshake::Handler::Client76#generate_key`/`Client04#key` use `Kernel#rand`
  rather than `SecureRandom` to generate handshake nonces. Per both specs
  these values don't need to be cryptographically unpredictable (they exist
  to detect caching proxies, not to authenticate anything), so this was left
  as-is rather than changed speculatively. Noted here for visibility.

## Notable design decisions

- **`WebSocket.load_native_extension`**: the top-level
  `begin require 'websocket-native'; rescue LoadError; end` in `lib/websocket.rb`
  was extracted into a named module method. This was required to get 100%
  branch coverage on the "re-raise unrelated LoadErrors" path (which can only
  be exercised by stubbing `require`, and you can't stub inline top-level
  code), but it's also a net documentation/testability improvement on its
  own.
- Several coverage gaps were in genuinely unreachable-through-the-public-API
  defensive code (abstract `NotImplementedError` stubs, a `data.nil?` guard
  in `Handler07#valid_encoding?` that can never see `nil` because
  `Frame::Data.new` always coerces via `.to_s` first, and
  `reserved_leftover_lines` overrides in `Handshake::Handler::Client76`/
  `Server76` that — as far as I can tell — have been dead code since v1.1.0
  removed handler-extending, per the CHANGELOG's "stop extending handlers"
  entry: the handshake object never delegates to the handler for this
  method, so its own default (0) is always what's actually used). Rather than
  changing runtime behavior speculatively to make these reachable (risky,
  out of scope, and not requested), each is tested directly against the
  class/method in question, with a comment or spec description making clear
  it's a white-box test of the method's own contract rather than a simulated
  real-world path.
- Did not touch `autobahn-*.json`/the `rake autobahn:*` tasks — they invoke
  an external `wstest` binary not available in this environment and are
  unrelated to Ruby-version compatibility.
