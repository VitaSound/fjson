\ fjson/parse.4th — JSON text to tree.

require tree.4th

variable fjson.parse-start
variable fjson.parse-end
variable fjson.cur
variable fjson.tmp-len
variable fjson.parse-num

58 constant fjson.colon-char

: fjson.cur-in? ( -- f )
    fjson.cur @ fjson.parse-end @ < ;

: fjson.peek ( -- c )
    fjson.cur @ c@ ;

: fjson.advance ( -- )
    fjson.cur @ char+ fjson.cur ! ;

: fjson.ws? ( c -- f )
    dup bl = IF drop -1 EXIT THEN
    dup 9 = IF drop -1 EXIT THEN
    dup 10 = IF drop -1 EXIT THEN
    13 = ;

: fjson.skip-ws ( -- )
    begin
        fjson.cur-in? IF fjson.peek fjson.ws? ELSE 0 THEN
    while
        fjson.advance
    repeat ;

: fjson.take-char? ( c -- f )
    fjson.cur-in? IF
        fjson.peek over = IF
            drop fjson.advance -1
        ELSE
            drop 0
        THEN
    ELSE
        drop 0
    THEN ;

: fjson.tmp-add ( c -- )
    pad fjson.tmp-len @ + c!
    1 fjson.tmp-len +! ;

: fjson.hex-val ( c -- n f )
    dup [char] 0 [char] 9 1+ within IF
        [char] 0 - -1 EXIT
    THEN
    dup [char] A [char] F 1+ within IF
        [char] A - 10 + -1 EXIT
    THEN
    dup [char] a [char] f 1+ within IF
        [char] a - 10 + -1 EXIT
    THEN
    drop 0 0 ;

: fjson.take-hex ( -- n f )
    fjson.cur-in? 0= IF 0 0 EXIT THEN
    fjson.peek fjson.hex-val
    dup IF fjson.advance THEN ;

: fjson.parse-u00 ( -- c f )
    [char] u fjson.take-char? 0= IF 0 0 EXIT THEN
    [char] 0 fjson.take-char? 0= IF 0 0 EXIT THEN
    [char] 0 fjson.take-char? 0= IF 0 0 EXIT THEN
    fjson.take-hex 0= IF drop 0 0 EXIT THEN >r
    fjson.take-hex 0= IF drop rdrop 0 0 EXIT THEN
    r> 16 * + -1 ;

: fjson.parse-escape ( -- c f )
    [char] \ fjson.take-char? 0= IF 0 0 EXIT THEN
    fjson.cur-in? 0= IF 0 0 EXIT THEN
    fjson.peek [char] " = IF fjson.advance [char] " -1 EXIT THEN
    fjson.peek [char] \ = IF fjson.advance [char] \ -1 EXIT THEN
    fjson.peek [char] n = IF fjson.advance 10 -1 EXIT THEN
    fjson.peek [char] t = IF fjson.advance 9 -1 EXIT THEN
    fjson.peek [char] r = IF fjson.advance 13 -1 EXIT THEN
    fjson.peek [char] u = IF fjson.parse-u00 EXIT THEN
    0 0 ;

: fjson.parse-string-char ( -- f )
    fjson.peek [char] \ = IF
        fjson.parse-escape dup IF
            drop fjson.tmp-add -1
        ELSE
            2drop 0
        THEN
    ELSE
        fjson.peek fjson.tmp-add fjson.advance -1
    THEN ;

: fjson.parse-string ( -- node|0 )
    [char] " fjson.take-char? 0= IF 0 EXIT THEN
    0 fjson.tmp-len !
    begin
        fjson.cur-in?
    while
        fjson.peek [char] " = IF
            fjson.advance
            pad fjson.tmp-len @ fjson.str-dup fjson.node-str EXIT
        THEN
        fjson.parse-string-char 0= IF 0 EXIT THEN
    repeat
    0 ;

: fjson.parse-uint ( -- node|0 )
    fjson.cur-in? 0= IF 0 EXIT THEN
    fjson.peek fjson.digit? 0= IF 0 EXIT THEN
    0 fjson.parse-num !
    begin
        fjson.cur-in? IF fjson.peek fjson.digit? ELSE 0 THEN
    while
        fjson.parse-num @ 10 * fjson.peek [char] 0 - + fjson.parse-num !
        fjson.advance
    repeat
    fjson.parse-num @ fjson.node-num ;

defer fjson.parse-value

: fjson.finish-array ( lst -- node )
    dup ulist-reverse fjson.node-arr ;

: fjson.parse-array ( -- node|0 )
    [char] [ fjson.take-char? 0= IF 0 EXIT THEN
    ulist-new >r
    fjson.skip-ws
    [char] ] fjson.take-char? IF r> fjson.finish-array EXIT THEN
    begin
        fjson.parse-value dup 0= IF
            drop r> fjson.ulist-free-nodes 0 EXIT
        THEN
        r@ ulist-add
        fjson.skip-ws
        [char] ] fjson.take-char? IF r> fjson.finish-array EXIT THEN
        [char] , fjson.take-char? 0= IF r> fjson.ulist-free-nodes 0 EXIT THEN
        fjson.skip-ws
    again ;

: fjson.finish-object ( lst -- node )
    dup ulist-reverse fjson.node-obj ;

: fjson.parse-object ( -- node|0 )
    [char] { fjson.take-char? 0= IF 0 EXIT THEN
    ulist-new >r
    fjson.skip-ws
    [char] } fjson.take-char? IF r> fjson.finish-object EXIT THEN
    begin
        fjson.parse-string dup 0= IF
            drop r> fjson.ulist-free-pairs 0 EXIT
        THEN
        >r
        fjson.skip-ws
        fjson.colon-char fjson.take-char? 0= IF
            r> fjson.node-free
            r> fjson.ulist-free-pairs 0 EXIT
        THEN
        fjson.skip-ws
        fjson.parse-value dup 0= IF
            drop r> fjson.node-free
            r> fjson.ulist-free-pairs 0 EXIT
        THEN
        r@ fjson.node-str@ rot fjson.pair-new
        r> fjson.node-free
        r@ ulist-add
        fjson.skip-ws
        [char] } fjson.take-char? IF r> fjson.finish-object EXIT THEN
        [char] , fjson.take-char? 0= IF r> fjson.ulist-free-pairs 0 EXIT THEN
        fjson.skip-ws
    again ;

:noname ( -- node|0 )
    fjson.skip-ws
    fjson.cur-in? 0= IF 0 EXIT THEN
    fjson.peek [char] { = IF fjson.parse-object EXIT THEN
    fjson.peek [char] [ = IF fjson.parse-array EXIT THEN
    fjson.peek [char] " = IF fjson.parse-string EXIT THEN
    fjson.peek fjson.digit? IF fjson.parse-uint EXIT THEN
    0 ;
is fjson.parse-value

: fjson.parse ( text-a text-u -- node|0 )
    over fjson.parse-start !
    over + fjson.parse-end !
    fjson.cur !
    fjson.parse-value dup 0= IF EXIT THEN
    fjson.skip-ws
    fjson.cur @ fjson.parse-end @ = IF
        EXIT
    THEN
    dup fjson.node-free drop
    0 ;
