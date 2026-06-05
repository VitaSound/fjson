\ tests/fjson_roundtrip_test.4th — parse, emit, parse again.

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../forth-packages/fenum/0.1.1/fenum.4th
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

: fjson.rt-write-pretty ( node -- )
    fjson.rt-path fjson.emit-to-file
    fjson.emit-node-pretty
    fjson.fid @ close-file throw
    fjson.emit-to-stdout ;

: fjson.rt-write-debug ( node -- )
    fjson.rt-path fjson.emit-to-file
    fjson.debug-node
    fjson.fid @ close-file throw
    fjson.emit-to-stdout ;

T{ s\" {\"key\":\"val\",\"n\":42,\"items\":[1,2]}" fjson.parse
    dup fjson.rt-root ! fjson.rt-write
    fjson.rt-slurp s\" {\"key\":\"val\",\"n\":42,\"items\":[1,2]}" compare -> 0 }T

T{ fjson.rt-slurp fjson.parse
    dup fjson.rt-root2 ! fjson.object-len -> 3 }T

T{ s" items" fjson.rt-root2 @ fjson.object-get
    dup fjson.array-len swap 1 swap fjson.array-nth fjson.node-num@ -> 2 2 }T

T{ fjson.rt-root @ fjson.rt-write-pretty
    fjson.rt-slurp
    s\" {\n  \"key\": \"val\",\n  \"n\": 42,\n  \"items\": [\n    1,\n    2\n  ]\n}" compare -> 0 }T

T{ fjson.rt-root @ fjson.rt-write-debug
    fjson.rt-slurp
    s\" node OBJ len=3\n  pair key=\"key\"\n    node STR \"val\"\n  pair key=\"n\"\n    node NUM 42\n  pair key=\"items\"\n    node ARR len=2\n      node NUM 1\n      node NUM 2\n" compare -> 0 }T

T{ fjson.rt-root @ fjson.node-free
    fjson.rt-root2 @ fjson.node-free -> }T

T{ s\" {\"ok\":true,\"off\":false,\"empty\":null}" fjson.parse
    dup fjson.rt-root ! fjson.rt-write
    fjson.rt-slurp
    s\" {\"ok\":true,\"off\":false,\"empty\":null}" compare -> 0 }T

T{ fjson.rt-slurp fjson.parse dup fjson.rt-root2 ! drop
    s" ok" fjson.rt-root2 @ fjson.object-get fjson.node-bool@ -> -1 }T

T{ s" off" fjson.rt-root2 @ fjson.object-get fjson.node-bool@ -> 0 }T

T{ s" empty" fjson.rt-root2 @ fjson.object-get fjson.node-null? -> -1 }T

T{ fjson.rt-root @ fjson.rt-write-pretty
    fjson.rt-slurp
    s\" {\n  \"ok\": true,\n  \"off\": false,\n  \"empty\": null\n}" compare -> 0 }T

T{ fjson.rt-root @ fjson.rt-write-debug
    fjson.rt-slurp
    s\" node OBJ len=3\n  pair key=\"ok\"\n    node BOOL true\n  pair key=\"off\"\n    node BOOL false\n  pair key=\"empty\"\n    node NULL\n" compare -> 0 }T

T{ fjson.rt-root @ fjson.node-free
    fjson.rt-root2 @ fjson.node-free -> }T

#ERRORS @ 0= [IF] ." fjson_roundtrip_test OK" cr [ELSE] ." fjson_roundtrip_test FAILED" cr [THEN]
