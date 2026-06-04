\ fjson/node.4th — JSON tree node structs.

require util.4th

variable fjson.load-depth

: fjson.mark-depth ( -- )
    depth fjson.load-depth ! ;

: fjson.drop-new-stack ( -- )
    depth fjson.load-depth @ - 0 ?do drop loop ;

fjson.mark-depth
[IFUNDEF] ulist-new
    require fenum.4th
[THEN]
fjson.drop-new-stack

0 constant FJSON_J-NULL
1 constant FJSON_J-BOOL
2 constant FJSON_J-NUM
3 constant FJSON_J-STR
4 constant FJSON_J-ARR
5 constant FJSON_J-OBJ

fjson.mark-depth
struct
    cell% field j-type
    cell% field j-num
    cell% field j-str-a
    cell% field j-str-u
    cell% field j-child
constant json-node%
fjson.drop-new-stack

fjson.mark-depth
struct
    cell% field pair-key-a
    cell% field pair-key-u
    cell% field pair-val
constant json-pair%
fjson.drop-new-stack

: fjson.node-new ( type -- node )
    json-node% allocate throw >r
    r@ j-type !
    0 r@ j-num !
    0 r@ j-str-a !
    0 r@ j-str-u !
    0 r@ j-child !
    r> ;

: fjson.node-type ( node -- type )
    j-type @ ;

: fjson.node-str@ ( node -- a u )
    dup j-type @ FJSON_J-STR = IF
        dup j-str-a @ swap j-str-u @
    ELSE
        drop 0 0
    THEN ;

: fjson.node-num@ ( node -- u )
    dup j-type @ FJSON_J-NUM = IF j-num @ ELSE drop 0 THEN ;

: fjson.node-child ( node -- lst|0 )
    j-child @ ;

: fjson.node-str ( a u -- node )
    fjson.str-dup
    FJSON_J-STR fjson.node-new >r
    r@ j-str-u !
    r@ j-str-a !
    r> ;

: fjson.node-num ( u -- node )
    FJSON_J-NUM fjson.node-new >r
    r@ j-num !
    r> ;

: fjson.node-bool ( f -- node )
    FJSON_J-BOOL fjson.node-new >r
    r@ j-num !
    r> ;

: fjson.node-arr ( lst -- node )
    FJSON_J-ARR fjson.node-new >r
    r@ j-child !
    r> ;

: fjson.node-obj ( lst -- node )
    FJSON_J-OBJ fjson.node-new >r
    r@ j-child !
    r> ;

: fjson.pair-new ( key-a key-u val-node -- pair )
    >r fjson.str-dup
    json-pair% allocate throw >r
    r@ pair-key-u !
    r@ pair-key-a !
    r> r> over >r swap pair-val !
    r> ;
