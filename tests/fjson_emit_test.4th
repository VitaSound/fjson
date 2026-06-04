\ tests/fjson_emit_test.4th — JSON write (quoted, uint, object helpers).

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../forth-packages/fenum/0.1.1/fenum.4th
require ../fjson.4th

0 #ERRORS !

: fjson.test-out-path ( -- ca u ) s" /tmp/fjson_emit_test.json" ;

variable fjson.test-fid
variable fjson.test-len

: fjson.test-slurp ( -- buf bu )
    fjson.test-out-path r/o open-file throw fjson.test-fid !
    pad 256 fjson.test-fid @ read-file throw fjson.test-len !
    fjson.test-fid @ close-file throw
    pad fjson.test-len @ ;

: fjson.test-write ( -- )
    fjson.test-out-path fjson.emit-to-file
    fjson.object-open
    s" key" s" val" fjson.emit-key-string
    s" n" 42 fjson.key-uint
    fjson.object-close
    fjson.fid @ close-file throw
    fjson.emit-to-stdout ;

create fjson.test-ctrl 1 c,

: fjson.test-write-extra ( -- )
    fjson.test-out-path fjson.emit-to-file
    fjson.object-open
    s" arr" fjson.comma s\" \"" fjson.emit fjson.emit s\" \":" fjson.emit
    fjson.array-open 1 fjson.uint s\" ," fjson.emit 2 fjson.uint fjson.array-close
    s\" ," fjson.emit
    s" ok" fjson.comma s\" \"" fjson.emit fjson.emit s\" \":" fjson.emit
    s" true" fjson.raw
    s" c" fjson.comma s\" \"" fjson.emit fjson.emit s\" \":" fjson.emit
    fjson.test-ctrl 1 fjson.quoted
    fjson.object-close
    fjson.fid @ close-file throw
    fjson.emit-to-stdout ;

T{ fjson.test-write
    fjson.test-slurp
    s\" {\"key\":\"val\",\"n\":42}" compare -> 0 }T

T{ fjson.test-write-extra
    fjson.test-slurp
    s\" {\"arr\":[1,2],\"ok\":true,\"c\":\"\\u0001\"}" compare -> 0 }T

T{ fjson.emit-to-stdout
    s\" \"x\"" fjson.quoted -> }T

#ERRORS @ 0= [IF] ." fjson_emit_test OK" cr [ELSE] ." fjson_emit_test FAILED" cr [THEN]
