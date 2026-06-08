# Change Log

All notable changes to fjson are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

## [0.2.5] - 2026-06-08

### Added
- GitHub Actions CI (Gforth 0.7.9, fmix 0.7.2, `fmix test`).
- License, Ver and Cov badges in `README.md`.

## [0.2.4] - 2026-06-05

### Added

- Tree parse support for JSON `true`, `false`, and `null` (`fjson.parse-bool`,
  `fjson.parse-null`).
- Node accessors: `fjson.node-bool@`, `fjson.node-null`, `fjson.node-null?`.
- Read-lite: `fjson.key-bool`, `fjson.key-null`.
- Emit/debug branches for `FJSON_J-NULL` and `FJSON_J-BOOL` typed nodes.
- Tests for bool/null in tree, read-lite, and roundtrip paths.

## [0.2.3] - 2026-06-05

### Fixed

- `fjson.parse-string` copies parsed text with `fjson.str-dup` instead of `pad`
  (safe repeated parse/free in one session).
- `fjson.pair-new` uses `fjson.pair-val-slot` instead of `>r` before `str-dup`
  (avoids allocate errors when building object trees).

## [0.2.2] - 2026-06-05

### Added

- Tests for parse escapes, `fjson.node-child`, emit `array-open`/`array-close`,
  `raw`, control-char `\u00` quoting, read-lite `digits-at`/`remain`, and
  `fjson.str-concat`.
- Explicit `fenum` require in fjson test files for reliable `fmix test`.

### Changed

- fcov colon definition coverage for `fjson/*.4th` is 100% under `fmix test`.

## [0.2.1] - 2026-06-05

### Added

- `fjson.debug-node` for inspecting parsed tree nodes.
- `fjson.emit-node-pretty` for indented JSON tree output.
- API cookbook showing parse, debug dump, compact emit, and pretty emit.

## [0.2.0] - 2026-06-05

Add an in-memory JSON tree layer while preserving the 0.1.0 read-lite and
emit APIs.

### Added

- **Tree nodes** (`fjson/node.4th`): tagged JSON node and object pair structs.
- **Traversal/lifecycle** (`fjson/tree.4th`): object lookup, array indexing,
  lengths, and recursive `fjson.node-free`.
- **Parser** (`fjson/parse.4th`): objects, arrays, strings, unsigned integers,
  whitespace, and basic string escapes.
- **Tree emit** (`fjson/emit-tree.4th`): `fjson.emit-node` round-trips parsed
  trees through existing emit primitives.
- Tests for tree access and parse/emit round-trip behavior.
- `fenum` `0.1.1` dependency for `ulist` containers.

## [0.1.0] - 2026-06-04

Initial public release. Minimal JSON **write** and **read-lite** for Gforth
(VitaSound toolchain). Not a full RFC 8259 parser — designed for flat
one-line JSON and NDJSON (MCP JSON-RPC).

### Added

- **Read-lite** (`fjson/read.4th`): substring search on a line buffer
  - `fjson.contains?` — haystack contains needle
  - `fjson.key-string` — value after `"key":` (quoted string values)
  - `fjson.key-digits` — unquoted integer after `"key":` (e.g. `"id":42`)
- **Write** (`fjson/emit.4th`): escape, quoted strings, uint, object/array
  helpers (same role as legacy `fcov.json-*` emitters).
- **Util** (`fjson/util.4th`): `fjson.str-dup`, `fjson.str-concat`,
  `fjson.u>str`.
- Entry point `fjson.4th`; `package.4th` for fmix / theforth.net.
- Tests: `tests/fjson_test.4th`, `tests/fjson_emit_test.4th`,
  `tests/some_test.4th` (ttester 1.2.1).
- fcov / flint pins in `package.4th`.

### Consumers

- **fmcp** — MCP JSON-RPC request parsing and response assembly.
- **fcov** — planned migration from inline JSON emitters (see fcov ROADMAP).
