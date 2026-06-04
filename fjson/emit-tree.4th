\ fjson/emit-tree.4th — JSON tree serialization.

require tree.4th
require emit.4th

defer fjson.emit-node

: fjson.emit-list-comma ( i -- )
    0> IF s\" ," fjson.emit THEN ;

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
    dup j-type @ FJSON_J-ARR = IF
        fjson.emit-array EXIT
    THEN
    dup j-type @ FJSON_J-OBJ = IF
        fjson.emit-object EXIT
    THEN
    drop s" null" fjson.emit ;
is fjson.emit-node
