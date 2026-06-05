\ fjson/read.4th — read-lite (flat JSON / NDJSON lines).

require util.4th

variable fjsonlinea
variable fjsonlineu
variable fjsonslen
variable fjsonstart
variable fjsonhay

34 constant fjson.quote-char

: fjson.search-off ( hay hlen suba slen -- off | -1 )
    3 pick fjsonhay !
    search
    dup IF
        drop swap fjsonstart ! drop
        fjsonstart @ fjsonhay @ -
    ELSE
        drop 2drop -1
    THEN ;

: fjson.digit? ( c -- f )
    [char] 0 [char] 9 1+ within ;

: fjson.in-line? ( addr -- f )
    fjsonlinea @ fjsonlineu @ + < ;

: fjson.scan-addr ( -- addr )
    fjsonstart @ fjsonslen @ + ;

: fjson.more-digits? ( -- f )
    fjson.scan-addr dup fjson.in-line? IF
        c@ fjson.digit?
    ELSE
        drop 0
    THEN ;

: fjson.more-string? ( -- f )
    fjson.scan-addr dup fjson.in-line? IF
        c@ fjson.quote-char <>
    ELSE
        drop 0
    THEN ;

: fjson.quoted-start? ( -- f )
    fjsonstart @ dup fjson.in-line? IF
        c@ fjson.quote-char =
    ELSE
        drop 0
    THEN ;

: fjson.contains? ( hay hlen suba slen -- f )
    fjson.search-off dup 0< IF drop 0 ELSE drop -1 THEN ;

: fjson.remain ( start -- u )
    fjsonlinea @ fjsonlineu @ + swap - ;

: fjson.copy-digits ( -- diga digu | 0 0 )
    fjsonslen @ 0= IF
        0 0
    ELSE
        fjsonstart @ fjsonslen @ fjson.str-dup
    THEN ;

: fjson.copy-string ( -- vala valu | 0 0 )
    fjson.scan-addr fjson.in-line? IF
        fjsonstart @ fjsonslen @ fjson.str-dup
    ELSE
        0 0
    THEN ;

: fjson.scan-digits ( -- diga digu | 0 0 )
    0 fjsonslen !
    begin
        fjson.more-digits?
    while
        1 fjsonslen +!
    repeat
    fjson.copy-digits ;

: fjson.scan-string ( -- vala valu | 0 0 )
    0 fjsonslen !
    begin
        fjson.more-string?
    while
        1 fjsonslen +!
    repeat
    fjson.copy-string ;

: fjson.value-after-key ( pos klen -- vala valu | 0 0 )
    fjsonlinea @ swap >r + r> + fjsonstart !
    fjson.quoted-start? IF
        fjsonstart @ char+ fjsonstart !
        fjson.scan-string
    ELSE
        0 0
    THEN ;

: fjson.key-string ( linea lineu keya klen -- vala valu | 0 0 )
    3 pick fjsonlinea !
    2 pick fjsonlineu !
    dup fjsonslen !
    fjson.search-off
    dup 0< IF drop 0 0 ELSE fjsonslen @ fjson.value-after-key THEN ;

: fjson.digits-at ( pos -- diga digu | 0 0 )
    fjsonlinea @ swap + fjsonstart !
    fjson.scan-digits ;

: fjson.digits-after-key ( pos klen -- diga digu | 0 0 )
    fjsonlinea @ swap >r + r> + fjsonstart !
    fjson.scan-digits ;

: fjson.key-digits ( linea lineu keya klen -- diga digu | 0 0 )
    3 pick fjsonlinea !
    2 pick fjsonlineu !
    dup fjsonslen !
    fjson.search-off
    dup 0< IF drop 0 0 EXIT THEN
    fjsonslen @ fjson.digits-after-key ;

: fjson.token-end? ( addr -- f )
    dup fjson.in-line? 0= IF drop -1 EXIT THEN
    c@ [char] a [char] z 1+ within 0=
    dup IF EXIT THEN
    c@ [char] A [char] Z 1+ within 0=
    dup IF EXIT THEN
    c@ [char] 0 [char] 9 1+ within 0= ;

: fjson.lit-at? { lit-a lit-u -- f }
    lit-u fjsonstart @ fjson.remain > IF 0 EXIT THEN
    lit-a lit-u fjsonstart @ lit-u compare 0= 0= IF 0 EXIT THEN
    lit-u fjsonstart @ + fjson.token-end? ;

create fjson-lit-true   116 c, 114 c, 117 c, 101 c,
create fjson-lit-false  102 c,  97 c, 108 c, 115 c, 101 c,
create fjson-lit-null   110 c, 117 c, 108 c, 108 c,

: fjson-lit-true@ ( -- a u ) fjson-lit-true 4 ;
: fjson-lit-false@ ( -- a u ) fjson-lit-false 5 ;
: fjson-lit-null@ ( -- a u ) fjson-lit-null 4 ;

: fjson.bool-at ( abs -- f found )
    fjsonstart !
    fjson-lit-true@ fjson.lit-at? IF -1 -1 EXIT THEN
    fjson-lit-false@ fjson.lit-at? IF 0 -1 EXIT THEN
    0 0 ;

: fjson.null-at ( abs -- found )
    fjsonstart !
    fjson-lit-null@ fjson.lit-at? ;

: fjson.bool-after-key ( pos klen -- f found )
    fjsonlinea @ swap >r + r> + fjson.bool-at ;

: fjson.null-after-key ( pos klen -- found )
    fjsonlinea @ swap >r + r> + fjson.null-at ;

: fjson.key-bool ( linea lineu keya klen -- f found )
    3 pick fjsonlinea !
    2 pick fjsonlineu !
    dup fjsonslen !
    fjson.search-off
    dup 0< IF drop 0 0 ELSE fjsonslen @ fjson.bool-after-key THEN ;

: fjson.key-null ( linea lineu keya klen -- found )
    3 pick fjsonlinea !
    2 pick fjsonlineu !
    dup fjsonslen !
    fjson.search-off
    dup 0< IF drop 0 ELSE fjsonslen @ fjson.null-after-key THEN ;
