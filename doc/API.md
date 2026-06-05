# fjson API reference

Minimal JSON **write**, **read-lite**, and **tree** support for Gforth. All words use the
`fjson.` prefix. Load with:

```forth
require fjson.4th
```

This pulls in read-lite, emit, and tree modules (and `fjson/util.4th`).

## Design

| Layer | Role |
|-------|------|
| **read-lite** | Scan a **single flat line** (typical MCP NDJSON). No nested object walk; keys are found by substring search. |
| **write** | Build JSON text to stdout or a file. RFC-style escaping for strings; integers via `fjson.uint`. |
| **tree** | Parse JSON text into allocated nodes backed by `fenum` `ulist`, traverse it, free it, and emit it again. |
| **util** | Allocated strings (`fjson.str-dup`, `fjson.str-concat`) used by read and by fmcp. |

**Not supported:** arrays in read-lite, floats, signed numbers,
and streaming multi-line documents.

---

## Read-lite (`fjson/read.4th`)

Internal line buffer is set by `fjson.key-string`, `fjson.key-digits`,
`fjson.key-bool`, and `fjson.key-null` from `( linea lineu … )`.

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

### `fjson.key-bool ( linea lineu keya klen -- f found )`

Find `"key":` then read an unquoted `true` / `false` literal.

- `found = -1`, `f = -1` → `true`
- `found = -1`, `f = 0` → `false`
- `found = 0` → key missing or value is not a boolean literal

Example:

```forth
s" {\"listChanged\":false}" s" \"listChanged\":" fjson.key-bool 0= . cr \ -1 (false)
```

### `fjson.key-null ( linea lineu keya klen -- found )`

Find `"key":` then read an unquoted `null` literal. Returns `found = -1` when
the value is exactly `null`, else `0`.

Example:

```forth
s" {\"x\":null}" s" \"x\":" fjson.key-null 0= . cr \ -1
```

---

## Write (`fjson/emit.4th`)

Default output is **stdout** (`fjson.emit-to-stdout`). Switch target with
`fjson.emit-to-file`.

### Output target

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.emit-to-stdout` | `( -- )` | Write subsequent emits to Gforth `stdout`. |
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

## Tree (`fjson/node.4th`, `fjson/tree.4th`, `fjson/parse.4th`, `fjson/emit-tree.4th`)

Tree nodes are allocated structs. The caller owns the root returned by
`fjson.parse` and must release it with `fjson.node-free`.

### Tags

| Constant | Value | Payload |
|----------|-------|---------|
| `FJSON_J-NULL` | `0` | null literal |
| `FJSON_J-BOOL` | `1` | boolean in `j-num` (`-1` = true, `0` = false) |
| `FJSON_J-NUM` | `2` | unsigned integer in `j-num` |
| `FJSON_J-STR` | `3` | allocated string in `j-str-a` / `j-str-u` |
| `FJSON_J-ARR` | `4` | `j-child` is a `ulist` of json-node addresses |
| `FJSON_J-OBJ` | `5` | `j-child` is a `ulist` of json-pair addresses |

Objects are stored as Erlang-style proplists: a `ulist` of `{ key, value }`
pairs. Arrays are `ulist` values. Parser insertion uses `ulist-add` and then
`ulist-reverse`, so traversal and emit preserve JSON order.

### Allocation and Access

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.node-new` | `( type -- node )` | Allocate a zeroed node with `j-type`. |
| `fjson.node-str` | `( a u -- node )` | Allocate a string node, copying the bytes. |
| `fjson.node-num` | `( u -- node )` | Allocate an unsigned integer node. |
| `fjson.node-bool` | `( f -- node )` | Allocate a boolean node (`-1` / `0`). |
| `fjson.node-null` | `( -- node )` | Allocate a null node. |
| `fjson.node-arr` | `( ulist -- node )` | Wrap an array list. |
| `fjson.node-obj` | `( ulist -- node )` | Wrap an object pair list. |
| `fjson.pair-new` | `( key-a key-u val-node -- pair )` | Allocate an object pair, copying the key. |
| `fjson.node-type` | `( node -- type )` | Return `FJSON_J-*`. |
| `fjson.node-str@` | `( node -- a u )` | String payload, or `0 0` if not a string. |
| `fjson.node-num@` | `( node -- u )` | Numeric payload, or `0` if not a number. |
| `fjson.node-bool@` | `( node -- f )` | Boolean payload (`-1` / `0`), or `0` if not a bool. |
| `fjson.node-null?` | `( node -- f )` | `-1` if `FJSON_J-NULL`, else `0`. |
| `fjson.node-child` | `( node -- ulist\|0 )` | Child list for arrays/objects. |
| `fjson.node-free` | `( node -- )` | Recursively free a node tree. |

### Parse

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.parse` | `( text-a text-u -- node\|0 )` | Parse one JSON value. Returns `0` on syntax failure. |

Parser support in `0.2.4`: objects, arrays, strings, unsigned decimal integers,
`true`, `false`, `null`, and whitespace outside strings. String escapes
supported: `\"`, `\\`, `\n`, `\t`, `\r`, and `\u00XX`.

### Traversal

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.object-get` | `( key-a key-u obj-node -- val-node\|0 )` | Linear key lookup in an object proplist. |
| `fjson.array-nth` | `( index arr-node -- val-node\|0 )` | 0-based array lookup. |
| `fjson.array-len` | `( arr-node -- n )` | Array length. |
| `fjson.object-len` | `( obj-node -- n )` | Object pair count. |

### Emit Tree

| Word | Stack | Description |
|------|-------|-------------|
| `fjson.emit-node` | `( node -- )` | Serialize a node tree to the current `fjson` output target. |
| `fjson.emit-node-pretty` | `( node -- )` | Serialize with indentation and newlines. |
| `fjson.debug-node` | `( node -- )` | Emit an indented Forth-side tree dump for debugging. |

Example:

```forth
s\" {\"key\":\"val\",\"n\":42}" fjson.parse dup
s" key" rot fjson.object-get fjson.node-str@ type cr
fjson.node-free
```

### Cookbook: parse, inspect, emit, pretty emit

This example uses every JSON value kind supported by the `0.2.x` tree layer:
object, array, string, unsigned integer, boolean, and null. Floats and signed
numbers are not parsed in this release.

Example input file:

```json
{"name":"fmix","version":2,"items":["read-lite","tree"],"meta":{"count":2}}
```

Test script:

```forth
require fjson.4th

variable fjson.example-root

: example-json ( -- a u )
    s\" {\"name\":\"fmix\",\"version\":2,\"items\":[\"read-lite\",\"tree\"],\"meta\":{\"count\":2}}" ;

\ 1. Parse a minimal JSON document that covers all supported tree types.
example-json fjson.parse fjson.example-root !

\ 2. Debug dump: show how JSON became Forth-side tagged nodes.
fjson.example-root @ fjson.debug-node

\ 3. Emit compact JSON again.
fjson.example-root @ fjson.emit-node cr

\ 4. Emit pretty JSON.
fjson.example-root @ fjson.emit-node-pretty cr

fjson.example-root @ fjson.node-free
```

Debug dump output:

```text
node OBJ len=4
  pair key="name"
    node STR "fmix"
  pair key="version"
    node NUM 2
  pair key="items"
    node ARR len=2
      node STR "read-lite"
      node STR "tree"
  pair key="meta"
    node OBJ len=1
      pair key="count"
        node NUM 2
```

Compact JSON output:

```json
{"name":"fmix","version":2,"items":["read-lite","tree"],"meta":{"count":2}}
```

Pretty JSON output:

```json
{
  "name": "fmix",
  "version": 2,
  "items": [
    "read-lite",
    "tree"
  ],
  "meta": {
    "count": 2
  }
}
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
- Optional: nested read for small objects if needed.
