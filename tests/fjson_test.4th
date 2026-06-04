\ tests/fjson_test.4th — read-lite (key-string, key-digits, contains?).

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../forth-packages/fenum/0.1.1/fenum.4th
require ../fjson.4th

0 #ERRORS !

T{ s\" {\"id\":42}" s\" \"id\":" fjson.key-digits 2drop
    6 fjson.digits-at s\" 42" compare -> 0 }T

T{ s\" {\"id\":42}" s\" \"id\":"
    3 pick fjsonlinea ! 2 pick fjsonlineu !
    dup fjsonslen ! fjson.search-off drop
    fjsonstart @ fjson.remain -> 8 }T

T{ s" ab" s" cd" fjson.str-concat s" abcd" compare -> 0 }T

T{ s" x" s" y" fjson.str-concat fjson.str-free -> }T

T{ s\" {\"project_root\":\"/tmp/x\"}" s\" \"project_root\":" fjson.key-string
    s\" /tmp/x" compare -> 0 }T

T{ s\" {\"id\":\"42\"}" s\" \"id\":" fjson.key-string
    s\" 42" compare -> 0 }T

T{ s\" hello" s\" ell" fjson.contains? -> -1 }T
T{ s\" hello" s\" hello" fjson.contains? -> -1 }T
T{ s\" hello" s\" zzz" fjson.contains? -> 0 }T

T{ s\" {\"id\":42}" s\" \"id\":" fjson.key-digits
    s\" 42" compare -> 0 }T

T{ s\" {\"id\":42,\"name\":\"x\"}" s\" \"id\":" fjson.key-digits
    s\" 42" compare -> 0 }T

T{ s\" {\"id\":\"42\"}" s\" \"id\":" fjson.key-digits
    nip 0= -> -1 }T

T{ s\" {\"name\":\"x\"}" s\" \"id\":" fjson.key-digits -> 0 0 }T

#ERRORS @ 0= [IF] ." fjson_test OK" cr [ELSE] ." fjson_test FAILED" cr [THEN]
