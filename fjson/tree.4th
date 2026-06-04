\ fjson/tree.4th — JSON tree traversal and lifecycle.

require node.4th

variable fjson.find-key-a
variable fjson.find-key-u
variable fjson.find-val

defer fjson.node-free

: fjson.str-eq? ( a1 u1 a2 u2 -- f )
    compare 0= ;

: fjson.object-node? ( node -- f )
    j-type @ FJSON_J-OBJ = ;

: fjson.array-node? ( node -- f )
    j-type @ FJSON_J-ARR = ;

: fjson.object-len ( obj-node -- n )
    dup fjson.object-node? IF
        j-child @ ulist-len
    ELSE
        drop 0
    THEN ;

: fjson.array-len ( arr-node -- n )
    dup fjson.array-node? IF
        j-child @ ulist-len
    ELSE
        drop 0
    THEN ;

: fjson.array-nth ( index arr-node -- val-node|0 )
    dup fjson.array-node? IF
        j-child @ ulist-nth-addr
    ELSE
        2drop 0
    THEN ;

: fjson.object-match ( pair -- )
    fjson.find-val @ IF
        drop
    ELSE
        dup >r pair-key-a @ r@ pair-key-u @
        fjson.find-key-a @ fjson.find-key-u @ fjson.str-eq? IF
            r@ pair-val @ fjson.find-val !
        THEN
        rdrop
    THEN ;

: fjson.object-get ( key-a key-u obj-node -- val-node|0 )
    dup fjson.object-node? 0= IF
        2drop drop 0 EXIT
    THEN
    j-child @ >r
    fjson.find-key-u !
    fjson.find-key-a !
    0 fjson.find-val !
    ['] fjson.object-match r> ulist-each
    fjson.find-val @ ;

: fjson.pair-free ( pair -- )
    dup pair-key-a @ over pair-key-u @ fjson.str-free
    dup pair-val @ fjson.node-free
    free throw ;

: fjson.ulist-free-nodes ( lst -- )
    dup ['] fjson.node-free swap ulist-each
    ulist-dispose ;

: fjson.ulist-free-pairs ( lst -- )
    dup ['] fjson.pair-free swap ulist-each
    ulist-dispose ;

:noname ( node -- )
    dup 0= IF drop EXIT THEN
    dup j-type @ FJSON_J-STR = IF
        dup j-str-a @ over j-str-u @ fjson.str-free
    ELSE
        dup j-type @ FJSON_J-ARR = IF
            dup j-child @ fjson.ulist-free-nodes
        ELSE
            dup j-type @ FJSON_J-OBJ = IF
                dup j-child @ fjson.ulist-free-pairs
            THEN
        THEN
    THEN
    free throw ;
is fjson.node-free
