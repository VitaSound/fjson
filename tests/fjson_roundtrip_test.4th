\ tests/fjson_roundtrip_test.4th — parse, emit, parse again.

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../fjson.4th

0 #ERRORS !

variable fjson.rt-root
variable fjson.rt-root2
variable fjson.rt-fid
variable fjson.rt-len

: fjson.rt-path ( -- ca u ) s" /tmp/fjson_roundtrip_test.json" ;

: fjson.rt-slurp ( -- a u )
    fjson.rt-path r/o open-file throw fjson.rt-fid !
    pad 512 fjson.rt-fid @ read-file throw fjson.rt-len !
    fjson.rt-fid @ close-file throw
    pad fjson.rt-len @ ;

: fjson.rt-write ( node -- )
    fjson.rt-path fjson.emit-to-file
    fjson.emit-node
    fjson.fid @ close-file throw
    fjson.emit-to-stdout ;

T{ s\" {\"key\":\"val\",\"n\":42,\"items\":[1,2]}" fjson.parse
    dup fjson.rt-root ! fjson.rt-write
    fjson.rt-slurp s\" {\"key\":\"val\",\"n\":42,\"items\":[1,2]}" compare -> 0 }T

T{ fjson.rt-slurp fjson.parse
    dup fjson.rt-root2 ! fjson.object-len -> 3 }T

T{ s" items" fjson.rt-root2 @ fjson.object-get
    dup fjson.array-len swap 1 swap fjson.array-nth fjson.node-num@ -> 2 2 }T

T{ fjson.rt-root @ fjson.node-free
    fjson.rt-root2 @ fjson.node-free -> }T

#ERRORS @ 0= [IF] ." fjson_roundtrip_test OK" cr [ELSE] ." fjson_roundtrip_test FAILED" cr [THEN]
