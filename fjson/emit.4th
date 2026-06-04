\ fjson/emit.4th — JSON generation (for fmcp, future fcov migration).

require util.4th

variable fjson.fid

: fjson.emit-to-stdout ( -- ) stdout fjson.fid ! ;

fjson.emit-to-stdout

: fjson.emit-to-file ( patha pathu -- )
    w/o create-file throw fjson.fid ! ;

: fjson.emit ( a u -- ) fjson.fid @ write-file throw ;

: fjson.emit-c ( c -- ) pad c! pad 1 fjson.emit ;

: fjson.hex-digit ( n -- c )
    dup 10 < IF [char] 0 + ELSE 10 - [char] a + THEN ;

: fjson.escape-char ( c -- )
    dup [char] " = IF drop s\" \\\"" fjson.emit EXIT THEN
    dup [char] \ = IF drop s\" \\\\" fjson.emit EXIT THEN
    dup 8  = IF drop s\" \\b"  fjson.emit EXIT THEN
    dup 9  = IF drop s\" \\t"  fjson.emit EXIT THEN
    dup 10 = IF drop s\" \\n"  fjson.emit EXIT THEN
    dup 12 = IF drop s\" \\f"  fjson.emit EXIT THEN
    dup 13 = IF drop s\" \\r"  fjson.emit EXIT THEN
    dup 32 < IF
        s\" \\u00" fjson.emit
        dup 16 / fjson.hex-digit fjson.emit-c
        16 mod fjson.hex-digit fjson.emit-c
        EXIT
    THEN
    fjson.emit-c ;

: fjson.escape ( a u -- )
    0 ?do dup c@ fjson.escape-char 1+ loop drop ;

: fjson.quoted ( a u -- )
    s\" \"" fjson.emit fjson.escape s\" \"" fjson.emit ;

: fjson.raw ( a u -- ) fjson.emit ;

: fjson.uint ( u -- ) fjson.u>str fjson.emit ;

variable fjson.comma?

: fjson.comma-reset ( -- ) 0 fjson.comma? ! ;

: fjson.comma ( -- )
    fjson.comma? @ IF s\" ," fjson.emit ELSE 1 fjson.comma? ! THEN ;

: fjson.object-open ( -- ) s\" {" fjson.emit fjson.comma-reset ;

: fjson.object-close ( -- ) s\" }" fjson.emit ;

: fjson.array-open ( -- ) s\" [" fjson.emit fjson.comma-reset ;

: fjson.array-close ( -- ) s\" ]" fjson.emit ;

: fjson.emit-key-string ( keya keyu vala valu -- )
    2>r
    fjson.comma
    s\" \"" fjson.emit
    fjson.emit
    s\" \":" fjson.emit
    2r> fjson.quoted ;

: fjson.key-uint ( keya keyu u -- )
    >r
    fjson.comma
    s\" \"" fjson.emit
    fjson.emit
    s\" \":" fjson.emit
    r> fjson.uint ;
