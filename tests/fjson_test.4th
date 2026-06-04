\ tests/fjson_test.4th — read-lite (key-string, key-digits, contains?).

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../fjson.4th

0 #ERRORS !

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
