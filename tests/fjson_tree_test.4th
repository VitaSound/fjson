\ tests/fjson_tree_test.4th — JSON tree parse/access/free.

require ../forth-packages/ttester/1.2.1/ttester.4th
require ../forth-packages/fenum/0.1.1/fenum.4th
require ../fjson.4th

0 #ERRORS !

variable fjson.test-root
variable fjson.test-node

T{ s\" {\"name\":\"fmix\",\"n\":42}" fjson.parse
    dup fjson.test-root ! fjson.node-type -> FJSON_J-OBJ }T

T{ s" name" fjson.test-root @ fjson.object-get
    fjson.node-str@ s" fmix" compare -> 0 }T

T{ s" n" fjson.test-root @ fjson.object-get
    fjson.node-num@ -> 42 }T

T{ s" missing" fjson.test-root @ fjson.object-get -> 0 }T

T{ fjson.test-root @ fjson.node-free -> }T

T{ s\" {\"params\":{\"project_root\":\"/tmp\"}}" fjson.parse
    dup fjson.test-root ! s" params" rot fjson.object-get
    dup fjson.test-node ! fjson.node-type -> FJSON_J-OBJ }T

T{ s" project_root" fjson.test-node @ fjson.object-get
    fjson.node-str@ s" /tmp" compare -> 0 }T

T{ fjson.test-root @ fjson.node-free -> }T

T{ s" [1,2,3]" fjson.parse
    dup fjson.test-root ! dup fjson.node-type swap fjson.array-len -> FJSON_J-ARR 3 }T

T{ 1 fjson.test-root @ fjson.array-nth fjson.node-num@ -> 2 }T

T{ fjson.test-root @ fjson.node-free -> }T

T{ s\" {\"a\":1}" fjson.parse fjson.node-free
    s\" {\"a\":1}" fjson.parse fjson.node-free -> }T

T{ s\" {\"k\":\"a\\nb\\t\\\"\\\\\\u0041\"}" fjson.parse fjson.test-root !
    s" k" fjson.test-root @ fjson.object-get fjson.node-str@
    s\" a\nb\t\"\\A" compare -> 0
    fjson.test-root @ fjson.node-free }T

T{ s" [10,20]" fjson.parse dup >r fjson.node-child ulist-len -> 2
    r> fjson.node-free }T

T{ s\" {\"a\":false}" fjson.parse dup fjson.test-root ! drop
    s" a" fjson.test-root @ fjson.object-get fjson.node-bool@ -> 0
    fjson.test-root @ fjson.node-free }T

T{ s\" {\"a\":false}" fjson.parse dup fjson.test-root ! drop
    s" a" fjson.test-root @ fjson.object-get fjson.node-type -> FJSON_J-BOOL
    fjson.test-root @ fjson.node-free }T

T{ s\" {\"a\":true}" fjson.parse dup fjson.test-root ! drop
    s" a" fjson.test-root @ fjson.object-get fjson.node-bool@ -> -1
    fjson.test-root @ fjson.node-free }T

T{ s\" {\"listChanged\":false}" fjson.parse dup fjson.test-root ! drop
    s" listChanged" fjson.test-root @ fjson.object-get fjson.node-bool@ -> 0
    fjson.test-root @ fjson.node-free }T

T{ s\" {\"a\":null}" fjson.parse dup fjson.test-root ! drop
    s" a" fjson.test-root @ fjson.object-get fjson.node-null? -> -1
    fjson.test-root @ fjson.node-free }T

T{ s\" {\"a\":null}" fjson.parse dup fjson.test-root ! drop
    s" a" fjson.test-root @ fjson.object-get fjson.node-type -> FJSON_J-NULL
    fjson.test-root @ fjson.node-free }T

T{ s" [true,false,true]" fjson.parse dup fjson.test-root ! drop
    0 fjson.test-root @ fjson.array-nth fjson.node-bool@ -> -1 }T

T{ 1 fjson.test-root @ fjson.array-nth fjson.node-bool@ -> 0 }T

T{ 2 fjson.test-root @ fjson.array-nth fjson.node-bool@ -> -1
    fjson.test-root @ fjson.node-free }T

T{ s" [null,1]" fjson.parse dup fjson.test-root ! drop
    0 fjson.test-root @ fjson.array-nth fjson.node-null? -> -1 }T

T{ 1 fjson.test-root @ fjson.array-nth fjson.node-num@ -> 1
    fjson.test-root @ fjson.node-free }T

T{ s" true" fjson.parse dup fjson.node-bool@ swap fjson.node-free -> -1 }T
T{ s" false" fjson.parse dup fjson.node-bool@ swap fjson.node-free -> 0 }T
T{ s" null" fjson.parse dup fjson.node-null? swap fjson.node-free -> -1 }T

T{ s" tru" fjson.parse -> 0 }T
T{ s" trueish" fjson.parse -> 0 }T
T{ s" nul" fjson.parse -> 0 }T
T{ s" nullable" fjson.parse -> 0 }T

T{ s\" {\"a\":\"x\"}" fjson.parse dup >r s" a" rot fjson.object-get
    fjson.node-bool@ r> fjson.node-free -> 0 }T

T{ s\" {\"n\":1}" fjson.parse dup >r s" n" rot fjson.object-get
    fjson.node-null? r> fjson.node-free -> 0 }T

T{ fjson.node-null dup fjson.node-null? swap fjson.node-free -> -1 }T
T{ -1 fjson.node-bool dup fjson.node-bool@ swap fjson.node-free -> -1 }T
T{ 0 fjson.node-bool dup fjson.node-bool@ swap fjson.node-free -> 0 }T

#ERRORS @ 0= [IF] ." fjson_tree_test OK" cr [ELSE] ." fjson_tree_test FAILED" cr [THEN]
