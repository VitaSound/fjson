\ fjson/util.4th

[IFUNDEF] fjson.str-dup

: fjson.str-dup { a u -- a-new u }
    u allocate throw { mem }
    a mem u move
    mem u ;

: fjson.str-concat { a1 u1 a2 u2 -- a3 u3 }
    u1 u2 + allocate throw { mem }
    a1 mem u1 move
    a2 mem u1 + u2 move
    mem u1 u2 + ;

: fjson.str-free ( a u -- )
    drop dup IF free throw ELSE drop THEN ;

: fjson.u>str ( u -- a u )
    0 <# #s #> fjson.str-dup ;

[THEN]
