# fjson API reference

Minimal JSON **write** and **read-lite** for Gforth. All words use the
`fjson.` prefix. Load with:

```forth
require fjson.4th
```

This pulls in `fjson/read.4th` and `fjson/emit.4th` (and `fjson/util.4th`).

## Design

| Layer | Role |
|-------|------|
| **read-lite** | Scan a **single flat line** (typical MCP NDJSON). No nested object walk; keys are found by substring search. |
| **write** | Build JSON text to stdout or a file. RFC-style escaping for strings; integers via `fjson.uint`. |
| **util** | Allocated strings (`fjson.str-dup`, `fjson.str-concat`) used by read and by fmcp. |

**Not supported:** arrays in read-lite, Unicode beyond ASCII escapes, floats,
`true`/`false`/`null` parsing, streaming multi-line documents.

---

## Read-lite (`fjson/read.4th`)

Internal line buffer is set by `fjson.key-string` / `fjson.key-digits` from
`( linea lineu … )`.

### `fjson.contains? ( hay hlen suba slen -- f )`

Returns `-1` if `sub` occurs in `hay`, else `0`. Uses Forth `search`.

### `fjson.key-string ( linea lineu keya klen -- vala valu | 0 0 )`

Find `"key":` in the line (key passed **with** opening quote, e.g.
`s" \"name\":"`), then return the **quoted** string value (without outer
quotes). Allocated copy via `fjson.str-dup`. Returns `0 0` if missing.

Example:

```forth
s" {\"name\":\"fmix\"}" s" \"name\":" fjson.key-string type cr \ fm mix
```

### `fjson.key-digits ( linea lineu keya klen -- diga digu | 0 0 )`

Find `"key":` then read an **unquoted** digit sequence (e.g. `"id":42`).
Returns `0 0` if key missing or value is quoted / non-numeric.

Example:

```forth
s" {\"id\":42}" s" \"id\":" fjson.key-digits type cr \ 42
```

---

## Write (`fjson/emit.4th`)

Default output is **stdout** (`fjson.emit-to-stdout`). Switch target with
`fjson.emit-to-file`.

### Output target

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.emit-to-stdout` | `( -- )` | Write subsequent emits to stdout (fileid 1). |
| `fjson.emit-to-file` | `( patha pathu -- )` | Open path for writing; subsequent emits go there. |

### Primitives

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.emit` | `( a u -- )` | Write raw bytes to current target. |
| `fjson.emit-c` | `( c -- )` | Write one character. |
| `fjson.quoted` | `( a u -- )` | JSON string with `"` and escapes. |
| `fjson.raw` | `( a u -- )` | Alias of `fjson.emit`. |
| `fjson.uint` | `( u -- )` | Unsigned decimal integer. |

### Object / array helpers

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.object-open` | `( -- )` | `{` and reset comma state. |
| `fjson.object-close` | `( -- )` | `}` |
| `fjson.array-open` | `( -- )` | `[` and reset comma state. |
| `fjson.array-close` | `( -- )` | `]` |
| `fjson.emit-key-string` | `( keya keyu vala valu -- )` | `"key":"value"` with comma. |
| `fjson.key-uint` | `( keya keyu u -- )` | `"key":N` with comma. |

Example:

```forth
s" out.json" fjson.emit-to-file
fjson.object-open
s" ok" s" true" fjson.emit-key-string   \ string value as-is in quotes
s" n" 3 fjson.key-uint
fjson.object-close
```

---

## Util (`fjson/util.4th`)

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.str-dup` | `( a u -- a-new u )` | Allocate and copy. |
| `fjson.str-concat` | `( a1 u1 a2 u2 -- a3 u3 )` | Allocate concatenation. |
| `fjson.str-free` | `( a u -- )` | `free` if non-zero address. |
| `fjson.u>str` | `( u -- a u )` | Decimal string (allocated or `s" 0"`). |

---

## Testing and quality

```bash
fmix test          # ttester unit tests
fcov run && fcov report   # definition coverage (target: grow emit + read)
flint              # duplicate-word scan (ignore ttester in forth-packages/)
```

Tests must be named `*_test.4th` and require ttester 1.2.1.

---

## Roadmap

- fcov: replace inline `fcov.json-*` with fjson emitters.
- Optional: `fjson.key-bool`, nested read for small objects if needed.
