# fjson

Minimal **JSON write** and **read-lite** for Gforth (VitaSound). Not a full RFC parser.

- **Write** — escape, quoted strings, uint, object/array helpers (same role as `fcov.json-*`, for a future fcov migration).
- **Read-lite** — `fjson.contains?`, `fjson.key-string`, `fjson.key-digits` on one-line flat JSON (MCP NDJSON).

No JSON package in [theforth.net-packages](https://github.com/theforth/theforth.net-packages) catalog; this fills that gap for our toolchain.

## Install

```bash
git clone git@github.com:VitaSound/fjson.git
cd fjson && fmix packages.get
```

## Usage

```forth
require fjson.4th

\ read
s" {\"name\":\"fmix_test\"}" s" \"name\":" fjson.key-string type cr

\ write
s" out.json" fjson.emit-to-file
s" {" fjson.emit
s" \"ok\"" fjson.quoted
s" }" fjson.emit
```

## Consumers

- **fmcp** — MCP JSON-RPC
- **fcov** — TODO: replace `fcov/collect.4th` json emitters with fjson (see `doc/ROADMAP.md` in fcov)

## Tests

```bash
fmix test
```

`fjson.key-digits` targets unquoted numbers (`{"id":42}`); quoted values use `fjson.key-string`.

## Documentation

- [doc/API.md](doc/API.md) — full word list, stack effects, examples, testing notes.
- [CHANGELOG.md](CHANGELOG.md) — release history.

Forth style: [frules](https://github.com/VitaSound/frules).
