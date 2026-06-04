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
    fjsonlinea @ + fjsonstart !
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
