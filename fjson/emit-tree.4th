\ fjson/emit-tree.4th — JSON tree serialization.

require tree.4th
require emit.4th

defer fjson.emit-node
defer fjson.emit-node-pretty-depth
defer fjson.debug-node-depth

: fjson.emit-list-comma ( i -- )
    0> IF s\" ," fjson.emit THEN ;

: fjson.emit-nl ( -- )
    10 fjson.emit-c ;

: fjson.emit-spaces ( n -- )
    0 ?do bl fjson.emit-c loop ;

: fjson.emit-indent ( depth -- )
    2 * fjson.emit-spaces ;

: fjson.emit-nl-indent ( depth -- )
    fjson.emit-nl fjson.emit-indent ;

: fjson.emit-pair ( pair -- )
    dup >r pair-key-a @ r@ pair-key-u @ fjson.quoted
    s\" :" fjson.emit
    r> pair-val @ fjson.emit-node ;

: fjson.emit-array ( node -- )
    s\" [" fjson.emit
    j-child @ { lst }
    lst ulist-len 0 ?do
        i fjson.emit-list-comma
        i lst ulist-nth-addr fjson.emit-node
    loop
    s\" ]" fjson.emit ;

: fjson.emit-object ( node -- )
    s\" {" fjson.emit
    j-child @ { lst }
    lst ulist-len 0 ?do
        i fjson.emit-list-comma
        i lst ulist-nth-addr fjson.emit-pair
    loop
    s\" }" fjson.emit ;

:noname ( node -- )
    dup 0= IF drop s" null" fjson.emit EXIT THEN
    dup j-type @ FJSON_J-STR = IF
        fjson.node-str@ fjson.quoted EXIT
    THEN
    dup j-type @ FJSON_J-NUM = IF
        fjson.node-num@ fjson.uint EXIT
    THEN
    dup j-type @ FJSON_J-NULL = IF
        drop s" null" fjson.emit EXIT
    THEN
    dup j-type @ FJSON_J-BOOL = IF
        j-num @ IF s" true" ELSE s" false" THEN fjson.raw EXIT
    THEN
    dup j-type @ FJSON_J-ARR = IF
        fjson.emit-array EXIT
    THEN
    dup j-type @ FJSON_J-OBJ = IF
        fjson.emit-object EXIT
    THEN
    drop s" null" fjson.emit ;
is fjson.emit-node

: fjson.emit-pair-pretty { pair depth -- }
    pair pair-key-a @ pair pair-key-u @ fjson.quoted
    s" : " fjson.emit
    pair pair-val @ depth fjson.emit-node-pretty-depth ;

: fjson.emit-array-pretty { node depth -- }
    s" [" fjson.emit
    node j-child @ { lst }
    lst ulist-len { len }
    len 0> IF
        len 0 ?do
            i fjson.emit-list-comma
            depth 1+ fjson.emit-nl-indent
            i lst ulist-nth-addr depth 1+ fjson.emit-node-pretty-depth
        loop
        depth fjson.emit-nl-indent
    THEN
    s" ]" fjson.emit ;

: fjson.emit-object-pretty { node depth -- }
    s" {" fjson.emit
    node j-child @ { lst }
    lst ulist-len { len }
    len 0> IF
        len 0 ?do
            i fjson.emit-list-comma
            depth 1+ fjson.emit-nl-indent
            i lst ulist-nth-addr depth 1+ fjson.emit-pair-pretty
        loop
        depth fjson.emit-nl-indent
    THEN
    s" }" fjson.emit ;

:noname ( node depth -- )
    over 0= IF 2drop s" null" fjson.emit EXIT THEN
    over j-type @ FJSON_J-STR = IF
        drop fjson.node-str@ fjson.quoted EXIT
    THEN
    over j-type @ FJSON_J-NUM = IF
        drop fjson.node-num@ fjson.uint EXIT
    THEN
    over j-type @ FJSON_J-NULL = IF
        2drop s" null" fjson.emit EXIT
    THEN
    over j-type @ FJSON_J-BOOL = IF
        drop j-num @ IF s" true" ELSE s" false" THEN fjson.raw EXIT
    THEN
    over j-type @ FJSON_J-ARR = IF
        fjson.emit-array-pretty EXIT
    THEN
    over j-type @ FJSON_J-OBJ = IF
        fjson.emit-object-pretty EXIT
    THEN
    2drop s" null" fjson.emit ;
is fjson.emit-node-pretty-depth

: fjson.emit-node-pretty ( node -- )
    0 fjson.emit-node-pretty-depth ;

: fjson.debug-pair { pair depth -- }
    depth fjson.emit-indent
    s" pair key=" fjson.emit
    pair pair-key-a @ pair pair-key-u @ fjson.quoted
    fjson.emit-nl
    pair pair-val @ depth 1+ fjson.debug-node-depth ;

: fjson.debug-array { node depth -- }
    depth fjson.emit-indent
    s" node ARR len=" fjson.emit
    node fjson.array-len fjson.uint
    fjson.emit-nl
    node j-child @ { lst }
    lst ulist-len 0 ?do
        i lst ulist-nth-addr depth 1+ fjson.debug-node-depth
    loop ;

: fjson.debug-object { node depth -- }
    depth fjson.emit-indent
    s" node OBJ len=" fjson.emit
    node fjson.object-len fjson.uint
    fjson.emit-nl
    node j-child @ { lst }
    lst ulist-len 0 ?do
        i lst ulist-nth-addr depth 1+ fjson.debug-pair
    loop ;

:noname ( node depth -- )
    over 0= IF
        nip fjson.emit-indent s" node 0" fjson.emit fjson.emit-nl EXIT
    THEN
    over j-type @ FJSON_J-STR = IF
        fjson.emit-indent s" node STR " fjson.emit
        fjson.node-str@ fjson.quoted fjson.emit-nl EXIT
    THEN
    over j-type @ FJSON_J-NUM = IF
        fjson.emit-indent s" node NUM " fjson.emit
        fjson.node-num@ fjson.uint fjson.emit-nl EXIT
    THEN
    over j-type @ FJSON_J-NULL = IF
        fjson.emit-indent s" node NULL" fjson.emit fjson.emit-nl
        drop EXIT
    THEN
    over j-type @ FJSON_J-BOOL = IF
        fjson.emit-indent s" node BOOL " fjson.emit
        dup j-num @ IF s" true" ELSE s" false" THEN fjson.emit fjson.emit-nl
        drop EXIT
    THEN
    over j-type @ FJSON_J-ARR = IF
        fjson.debug-array EXIT
    THEN
    over j-type @ FJSON_J-OBJ = IF
        fjson.debug-object EXIT
    THEN
    fjson.emit-indent s" node UNKNOWN" fjson.emit fjson.emit-nl drop ;
is fjson.debug-node-depth

: fjson.debug-node ( node -- )
    0 fjson.debug-node-depth ;
