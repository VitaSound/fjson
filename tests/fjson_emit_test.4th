\ tests/fjson_emit_test.4th — JSON write (quoted, uint, object helpers).

require ../forth-packages/ttester/1.2.1/ttester.4th
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

T{ fjson.test-write
    fjson.test-slurp
    s\" {\"key\":\"val\",\"n\":42}" compare -> 0 }T

T{ fjson.emit-to-stdout
    s\" \"x\"" fjson.quoted -> }T

#ERRORS @ 0= [IF] ." fjson_emit_test OK" cr [ELSE] ." fjson_emit_test FAILED" cr [THEN]
