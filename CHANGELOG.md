# Change Log

All notable changes to fjson are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

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
